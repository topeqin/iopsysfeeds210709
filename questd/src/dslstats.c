/*
 *  dslstats.c - Quest U-bus daemon IOPSYS
 *
 *  Author: Martin K. Schröder, martin.schroder@inteno.se
 *
 *  Copyright © 2004-2007 Rémi Denis-Courmont.
 *  This program is free software: you can redistribute and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, versions 2 of the license.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <libubox/blobmsg.h>
#include <libubox/uloop.h>
#include <libubox/ustream.h>
#include <libubox/utils.h>

#include <libubus.h>

#include "questd.h"

#define DSLDEBUG(...) {} //printf(__VA_ARGS__)

void dslstats_init(struct dsl_stats *self){
	*self = (struct dsl_stats){0}; 
	self->mode = ""; 
	self->traffic = ""; 
	self->status = ""; 
	self->link_power_state = ""; 
	self->vdsl2_profile = ""; 
	/*self->snr = (UpDown){0,0}; 
	self->pwr = (UpDown){0,0}; 
	self->attn = (UpDown){0, 0}; 
	self->max_rate = (UpDown){0,0}; 
	self->msgc = (UpDown){0,0}; 
	*/
}

void dslstats_load(struct dsl_stats *self){
	FILE *fp;
	char line[128];
	char name[64]; 
	char sep[64]; 
	char arg1[64]; 
	char arg2[64]; 
	int i = 0;
	
	// start with default bearer 0 (we can support more later)
	DSLBearer *bearer = &self->bearers[0]; 
	DSLCounters *counters = &self->counters[0]; 
	int done = 0; 
	
	if(!(fp = popen("xdslctl info --stats", "r"))) return; 
	
	while(!done && fgets(line, sizeof(line), fp) != NULL) {
		name[0] = 0; arg1[0] = 0; arg2[0] = 0; 
		remove_newline(line);
		int narg = sscanf(line, "%[^\t]%[\t ]%[^\t]%[\t]%[^\t]", name, sep, arg1, sep, arg2); 
		//DSLDEBUG("LINE: %s, args:%d\n", line, narg); 
		switch(narg){
			case 0: { // sections
				if(strstr(line, "Bearer")){
					int id = 0; 
					if(sscanf(strstr(line, "Bearer"), "Bearer %d", sep, &id) > 0){
						if(id < DSLSTATS_BEARER_COUNT){
							bearer = &self->bearers[id];
							DSLDEBUG("Switching bearer: %d\n", id); 
						} 
					}
				} 
				// it is possible to add more stats like this though
				/*
				else if(strstr(name, "Latest 15 minutes time =") == name) counters = &self->counters[DSLSTATS_COUNTERS_CURRENT_15]; 
				else if(strstr(name, "Previous 15 minutes time =") == name) counters = &self->counters[DSLSTATS_COUNTERS_PREVIOUS_15]; 
				else if(strstr(name, "Latest 1 day time =") == name) counters = &self->counters[DSLSTATS_COUNTERS_CURRENT_DAY]; 
				else if(strstr(name, "Previous 1 day time =") == name) counters = &self->counters[DSLSTATS_COUNTERS_PREVIOUS_DAY]; 
				else if(strstr(name, "Since Link time =") == name) counters = &self->counters[DSLSTATS_COUNTERS_SINCE_LINK]; */
			} break; 
			case 1: { // various one liners
				if(strstr(line, "Total time =") == line) counters = &self->counters[DSLSTATS_COUNTER_TOTALS]; 
				else if(strstr(line, "Latest 15 minutes time =") == line) done = 1; // we stop parsing at this right now
				
			} break; 
			case 3: {
				if(strstr(name, "Link Power State") == name) self->link_power_state = strdup(arg1); 
				else if(strstr(name, "Mode") == name) self->mode = strdup(arg1); 
				else if(strstr(name, "VDSL2 Profile") == name) self->vdsl2_profile = strdup(arg1); 
				else if(strstr(name, "TPS") == name) self->traffic = strdup(arg1); 
				else if(strstr(name, "Trellis") == name){
					char tmp[2][64]; 
					if(sscanf(arg1, "U:%s /D:%s", tmp[0], tmp[1])){
						DSLDEBUG("TRELLIS: %s %s\n", tmp[0], tmp[1]); 
						if(strcmp(tmp[0], "ON") == 0) self->trellis.down = 1; 
						else self->trellis.down = 0; 
						if(strcmp(tmp[1], "ON") == 0) self->trellis.up = 1; 
						else self->trellis.up = 0; 
					}
				}
				else if(strstr(name, "Status") == name) self->status = strdup(arg1); 
				else if(strstr(name, "Bearer") == name){
					unsigned long id, up, down, ret; 
					if((ret = sscanf(arg1, "%d, Upstream rate = %lu Kbps, Downstream rate = %lu Kbps", &id, &up, &down)) == 3){
						if(id < DSLSTATS_BEARER_COUNT){
							bearer = &self->bearers[id]; 
							bearer->rate.up = up; 
							bearer->rate.down = down; 
							DSLDEBUG("Switching bearer: %d\n", id); 
						}
					}
				}
				else if(strstr(name, "Max") == name) {
					sscanf(arg1, "Upstream rate = %lf Kbps, Downstream rate = %lf Kbps", &bearer->max_rate.up, &bearer->max_rate.down); 
				}
				DSLDEBUG("PARSED: name:%s, arg1:%s\n", name, arg1); 
			} break; 
			case 5: {
				if(strstr(name, "SNR") == name) {
					self->snr.down = atof(arg1);
					self->snr.up = atof(arg2); 
				}
				else if(strstr(name, "Attn") == name){
					self->attn.down = atof(arg1);
					self->attn.up = atof(arg2); 
				} 
				else if(strstr(name, "Pwr") == name){
					self->pwr.down = atof(arg1); 
					self->pwr.up = atof(arg2); 
				}
				else if(strstr(name, "MSGc") == name){
					bearer->msgc.down = atof(arg1); 
					bearer->msgc.up = atof(arg2); 
				}
				else if(strstr(name, "B:") == name){
					bearer->b.down = atof(arg1); 
					bearer->b.up = atof(arg2); 
				}
				else if(strstr(name, "M:") == name){
					bearer->m.down = atof(arg1); 
					bearer->m.up = atof(arg2); 
				}
				else if(strstr(name, "T:") == name){
					bearer->t.down = atof(arg1); 
					bearer->t.up = atof(arg2); 
				}
				else if(strstr(name, "R:") == name){
					bearer->r.down = atof(arg1); 
					bearer->r.up = atof(arg2); 
				}
				else if(strstr(name, "S:") == name){
					bearer->s.down = atof(arg1); 
					bearer->s.up = atof(arg2); 
				}
				else if(strstr(name, "L:") == name){
					bearer->l.down = atof(arg1); 
					bearer->l.up = atof(arg2); 
				}
				else if(strstr(name, "D:") == name){
					bearer->d.down = atof(arg1); 
					bearer->d.up = atof(arg2); 
				}
				else if(strstr(name, "delay:") == name){
					bearer->delay.down = atof(arg1); 
					bearer->delay.up = atof(arg2); 
				}
				else if(strstr(name, "INP:") == name){
					bearer->inp.down = atof(arg1); 
					bearer->inp.up = atof(arg2); 
				}
				else if(strstr(name, "SF:") == name){
					bearer->sf.down = atoll(arg1); 
					bearer->sf.up = atoll(arg2); 
				}
				else if(strstr(name, "SFErr:") == name){
					bearer->sf_err.down = atoll(arg1); 
					bearer->sf_err.up = atoll(arg2); 
				}
				else if(strstr(name, "RS:") == name){
					bearer->rs.down = atoll(arg1); 
					bearer->rs.up = atoll(arg2); 
				}
				else if(strstr(name, "RSCorr:") == name){
					bearer->rs_corr.down = atoll(arg1); 
					bearer->rs_corr.up = atoll(arg2); 
				}
				else if(strstr(name, "RSUnCorr:") == name){
					bearer->rs_uncorr.down = atoll(arg1); 
					bearer->rs_uncorr.up = atoll(arg2); 
				}
				else if(strstr(name, "HEC:") == name){
					bearer->hec.down = atoll(arg1); 
					bearer->hec.up = atoll(arg2); 
				}
				else if(strstr(name, "OCD:") == name){
					bearer->ocd.down = atoll(arg1); 
					bearer->ocd.up = atoll(arg2); 
				}
				else if(strstr(name, "LCD:") == name){
					bearer->lcd.down = atoll(arg1); 
					bearer->lcd.up = atoll(arg2); 
				}
				else if(strstr(name, "Total Cells:") == name){
					bearer->total_cells.down = atoll(arg1); 
					bearer->total_cells.up = atoll(arg2); 
				}
				else if(strstr(name, "Data Cells:") == name){
					bearer->data_cells.down = atoll(arg1); 
					bearer->data_cells.up = atoll(arg2); 
				}
				else if(strstr(name, "Bit Errors:") == name){
					bearer->bit_errors.down = atoll(arg1); 
					bearer->bit_errors.up = atoll(arg2); 
				}
				else if(strstr(name, "ES:") == name){
					counters->es.down = atoll(arg1); 
					counters->es.up = atoll(arg2); 
				}
				else if(strstr(name, "SES:") == name){
					counters->ses.down = atoll(arg1); 
					counters->ses.up = atoll(arg2); 
				}
				else if(strstr(name, "UAS:") == name){
					counters->uas.down = atoll(arg1); 
					counters->uas.up = atoll(arg2); 
				}
				DSLDEBUG("PARSED: name:%s, arg1:%s, arg2:%s\n", name, arg1, arg2); 
			} break; 
			default: {
				DSLDEBUG("ERROR: line:%s, fcnt:%d, name:%s, arg1:%s, arg2:%s\n", line, narg, name, arg1, arg2); 
			}
		}
	}
	
	pclose(fp);
	
	/*
	local xdsl = sys.exec("xdslctl info --stats")
	local rv = { }

	rv = {
		mode	= xdsl:match("Mode:%s+(%S+%s+%S+%s+%S+)") or "",
		traffic	= xdsl:match("TPS%S+:%s+(%S+)%s+%S+") or "",
		status	= xdsl:match("Status:%s+(%S+)") or "",
		lps	= xdsl:match("Link Power State:%s+(%S+)") or "",
		trldn   = xdsl:match("Trellis:%s+%S+%s+/D:(%S+)%s+") or "",
		trlup   = xdsl:match("Trellis:%s+U:(%S+)%s+%S+") or "",
		snrdn   = xdsl:match("SNR%s+%S+%s+(%S+)%s+%S+") or 0,
		snrup   = xdsl:match("SNR%s+%S+%s+%S+%s+(%S+)") or 0,
		atndn   = xdsl:match("Attn%S+%s+(%S+)%s+%S+") or 0,
		atnup   = xdsl:match("Attn%S+%s+%S+%s+(%S+)") or 0,
		opwdn	= xdsl:match("Pwr%S+%s+(%S+)%s+%S+") or 0,
		opwup	= xdsl:match("Pwr%S+%s+%S+%s+(%S+)") or 0,
		artdn	= xdsl:match("Max:%s+%S+%s+%S+%s+%S+%s+%d+%s+%S+%s+Downstream rate = (%d+)%s+%S+") or 0,
		artup	= xdsl:match("Max:%s+Upstream rate = (%d+)%s+") or 0,
		rtedn	= xdsl:match("Bearer:%s+%d+%S+%s+%S+%s+%S+%s+%S+%s+%d+%s+%S+%s+Downstream rate = (%d+)%s+%S+") or 0,
		rteup	= xdsl:match("Bearer:%s+%d+%S+%s+Upstream rate = (%d+)%s+") or 0,
		msgdn   = xdsl:match("MSGc:%s+(%S+)%s+%S+") or 0,
		msgup   = xdsl:match("MSGc:%s+%S+%s+(%S+)") or 0,
		Bdn	= xdsl:match("B:%s+(%S+)%s+%S+") or 0,
		Bup	= xdsl:match("B:%s+%S+%s+(%S+)") or 0,
		Mdn	= xdsl:match("M:%s+(%S+)%s+%S+") or 0,
		Mup	= xdsl:match("M:%s+%S+%s+(%S+)") or 0,
		Tdn	= xdsl:match("T:%s+(%S+)%s+%S+") or 0,
		Tup	= xdsl:match("T:%s+%S+%s+(%S+)") or 0,
		Rdn	= xdsl:match("R:%s+(%S+)%s+%S+") or 0,
		Rup	= xdsl:match("R:%s+%S+%s+(%S+)") or 0,
		Sdn	= xdsl:match("S:%s+(%S+)%s+%S+") or 0,
		Sup	= xdsl:match("S:%s+%S+%s+(%S+)") or 0,
		Ldn	= xdsl:match("L:%s+(%S+)%s+%S+") or 0,
		Lup	= xdsl:match("L:%s+%S+%s+(%S+)") or 0,
		Ddn	= xdsl:match("D:%s+(%S+)%s+%S+") or 0,
		Dup	= xdsl:match("D:%s+%S+%s+(%S+)") or 0,
		dlydn	= xdsl:match("delay:%s+(%S+)%s+%S+") or 0,
		dlyup	= xdsl:match("delay:%s+%S+%s+(%S+)") or 0,
		inpdn	= xdsl:match("INP:%s+(%S+)%s+%S+") or 0,
		inpup	= xdsl:match("INP:%s+%S+%s+(%S+)") or 0,
		frmdn	= xdsl:match("SF:%s+(%S+)%s+%S+") or 0,
		frmup	= xdsl:match("SF:%s+%S+%s+(%S+)") or 0,
		sprdn	= xdsl:match("SFErr:%s+(%S+)%s+%S+") or 0,
		sprup	= xdsl:match("SFErr:%s+%S+%s+(%S+)") or 0,
		rswdn	= xdsl:match("RS:%s+(%S+)%s+%S+") or 0,
		rswup	= xdsl:match("RS:%s+%S+%s+(%S+)") or 0,
		rscdn	= xdsl:match("RSCorr:%s+(%S+)%s+%S+") or 0,
		rscup	= xdsl:match("RSCorr:%s+%S+%s+(%S+)") or 0,
		rsudn	= xdsl:match("RSUnCorr:%s+(%S+)%s+%S+") or 0,
		rsuup	= xdsl:match("RSUnCorr:%s+%S+%s+(%S+)") or 0,
		hecdn	= xdsl:match("HEC:%s+(%S+)%s+%S+") or 0,
		hecup	= xdsl:match("HEC:%s+%S+%s+(%S+)") or 0,
		ocddn	= xdsl:match("OCD:%s+(%S+)%s+%S+") or 0,
		ocdup	= xdsl:match("OCD:%s+%S+%s+(%S+)") or 0,
		lcddn	= xdsl:match("LCD:%s+(%S+)%s+%S+") or 0,
		lcdup	= xdsl:match("LCD:%s+%S+%s+(%S+)") or 0,
		tcldn	= xdsl:match("Total Cells:%s+(%S+)%s+%S+") or 0,
		tclup	= xdsl:match("Total Cells:%s+%S+%s+(%S+)") or 0,
		dcldn	= xdsl:match("Data Cells:%s+(%S+)%s+%S+") or 0,
		dclup	= xdsl:match("Data Cells:%s+%S+%s+(%S+)") or 0,
		berdn	= xdsl:match("Bit Errors:%s+(%S+)%s+%S+") or 0,
		berup	= xdsl:match("Bit Errors:%s+%S+%s+(%S+)") or 0,
		tesdn	= xdsl:match("ES:%s+(%S+)%s+%S+") or 0,
		tesup	= xdsl:match("ES:%s+%S+%s+(%S+)") or 0,
		tssdn	= xdsl:match("SES:%s+(%S+)%s+%S+") or 0,
		tssup	= xdsl:match("SES:%s+%S+%s+(%S+)") or 0,
		tuadn	= xdsl:match("UAS:%s+(%S+)%s+%S+") or 0,
		tuaup	= xdsl:match("UAS:%s+%S+%s+(%S+)") or 0
	}
	
	return rv
	*/
}

void dslstats_to_blob_buffer(struct dsl_stats *self, struct blob_buf *b){
	void *t, *array, *obj;
	DSLBearer *bearer = &self->bearers[0]; 
	DSLCounters *counter = &self->counters[DSLSTATS_COUNTER_TOTALS]; 
	//dslstats_load(self); 
	
	t = blobmsg_open_table(b, "dslstats");
	blobmsg_add_string(b, "mode", self->mode);
	blobmsg_add_string(b, "traffic", self->traffic);
	blobmsg_add_string(b, "status", self->status);
	blobmsg_add_string(b, "link_power_state", self->link_power_state);
	blobmsg_add_u8(b, "trellis_up", self->trellis.up); 
	blobmsg_add_u8(b, "trellis_down", self->trellis.down); 
	blobmsg_add_u32(b, "snr_up_x100", self->snr.up * 100); 
	blobmsg_add_u32(b, "snr_down_x100", self->snr.down * 100); 
	blobmsg_add_u32(b, "pwr_up_x100", self->pwr.up * 100); 
	blobmsg_add_u32(b, "pwr_down_x100", self->pwr.down * 100); 
	blobmsg_add_u32(b, "attn_up_x100", self->attn.up * 100); 
	blobmsg_add_u32(b, "attn_down_x100", self->attn.down * 100); 
	
	// add bearer data (currently only one bearer)
	array = blobmsg_open_array(b, "bearers"); 
		obj = blobmsg_open_table(b, NULL); 
			blobmsg_add_u32(b, "max_rate_up", bearer->max_rate.up); 
			blobmsg_add_u32(b, "max_rate_down", bearer->max_rate.down); 
			blobmsg_add_u32(b, "rate_up", bearer->rate.up); 
			blobmsg_add_u32(b, "rate_down", bearer->rate.down); 
			blobmsg_add_u32(b, "msgc_up", bearer->msgc.up); 
			blobmsg_add_u32(b, "msgc_down", bearer->msgc.down); 
			blobmsg_add_u32(b, "b_down", bearer->b.down); 
			blobmsg_add_u32(b, "b_up", bearer->b.up); 
			blobmsg_add_u32(b, "m_down", bearer->m.down); 
			blobmsg_add_u32(b, "m_up", bearer->m.up); 
			blobmsg_add_u32(b, "t_down", bearer->t.down); 
			blobmsg_add_u32(b, "t_up", bearer->t.up); 
			blobmsg_add_u32(b, "r_down", bearer->r.down); 
			blobmsg_add_u32(b, "r_up", bearer->r.up); 
			blobmsg_add_u32(b, "s_down_x10000", bearer->s.down * 10000); 
			blobmsg_add_u32(b, "s_up_x10000", bearer->s.up * 10000); 
			blobmsg_add_u32(b, "l_down", bearer->l.down); 
			blobmsg_add_u32(b, "l_up", bearer->l.up); 
			blobmsg_add_u32(b, "d_down", bearer->d.down); 
			blobmsg_add_u32(b, "d_up", bearer->d.up); 
			blobmsg_add_u32(b, "delay_down", bearer->delay.down); 
			blobmsg_add_u32(b, "delay_up", bearer->delay.up); 
			blobmsg_add_u32(b, "inp_down_x100", bearer->inp.down * 100); 
			blobmsg_add_u32(b, "inp_up_x100", bearer->inp.up * 100); 
			blobmsg_add_u64(b, "sf_down", bearer->sf.down); 
			blobmsg_add_u64(b, "sf_up", bearer->sf.up); 
			blobmsg_add_u64(b, "sf_err_down", bearer->sf_err.down); 
			blobmsg_add_u64(b, "sf_err_up", bearer->sf_err.up); 
			blobmsg_add_u64(b, "rs_down", bearer->rs.down); 
			blobmsg_add_u64(b, "rs_up", bearer->rs.up); 
			blobmsg_add_u64(b, "rs_corr_down", bearer->rs_corr.down); 
			blobmsg_add_u64(b, "rs_corr_up", bearer->rs_corr.up); 
			blobmsg_add_u64(b, "rs_uncorr_down", bearer->rs_uncorr.down); 
			blobmsg_add_u64(b, "rs_uncorr_up", bearer->rs_uncorr.up); 
			blobmsg_add_u64(b, "hec_down", bearer->hec.down); 
			blobmsg_add_u64(b, "hec_up", bearer->hec.up); 
			blobmsg_add_u64(b, "ocd_down", bearer->ocd.down); 
			blobmsg_add_u64(b, "ocd_up", bearer->ocd.up); 
			blobmsg_add_u64(b, "lcd_down", bearer->lcd.down); 
			blobmsg_add_u64(b, "lcd_up", bearer->lcd.up); 
			blobmsg_add_u64(b, "total_cells_down", bearer->total_cells.down); 
			blobmsg_add_u64(b, "total_cells_up", bearer->total_cells.up); 
			blobmsg_add_u64(b, "data_cells_down", bearer->data_cells.down); 
			blobmsg_add_u64(b, "data_cells_up", bearer->data_cells.up); 
			blobmsg_add_u64(b, "bit_errors_down", bearer->bit_errors.down); 
			blobmsg_add_u64(b, "bit_errors_up", bearer->bit_errors.up); 
		blobmsg_close_table(b, obj); 
	blobmsg_close_array(b, array); 
	
	// add counter data (currently only totals)
	//counter = &self->counters[DSLSTATS_COUNTER_TOTALS]; 
	array = blobmsg_open_table(b, "counters"); 
		obj = blobmsg_open_table(b, "totals"); 
			blobmsg_add_u64(b, "es_down", counter->es.down); 
			blobmsg_add_u64(b, "es_up", counter->es.up); 
			blobmsg_add_u64(b, "ses_down", counter->ses.down); 
			blobmsg_add_u64(b, "ses_up", counter->ses.up); 
			blobmsg_add_u64(b, "uas_down", counter->uas.down); 
			blobmsg_add_u64(b, "uas_up", counter->uas.up); 
		blobmsg_close_table(b, obj); 
	blobmsg_close_array(b, array); 
	
	blobmsg_close_table(b, t);
}
