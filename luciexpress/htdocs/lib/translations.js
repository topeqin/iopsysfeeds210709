angular.module('gettext').run(['gettextCatalog', function (gettextCatalog) {
/* jshint -W100 */
    gettextCatalog.setStrings('en', {});
    gettextCatalog.setStrings('se', {"About":"Om","Actual Data Rate":"Nuvarande hastighet","Bit Rate":"Bithastighet","CRC Errors":"CRC fel","Cell Counter":"Cell räknare","Configured":"Konfigurerad","Current":"Nuvarande","DSL Connection":"DSL uppkoppling","DSL Mode":"DSL Mode","DSL Status Information":"DSL Status","Downstream":"Ner","Error Counter":"Fel","FEC Corrections":"FEC rättelser","Free":"Tillgänglig","Indicator Name":"Indikatornamn","Line Status":"Uppkopplingsstatus","Link Type":"Uppkopplingstyp","Loop Attenuation":"Loop attenuation","Operating Data":"Operationsdata","Received Cells":"Mottagna cells","SNR Margin":"SNR tolerans","Statistics":"Statistik","Test":"Jag testar","Transmitted Cells":"Celler sänt","Upstream":"Upp"});
/* jshint +W100 */
}]);