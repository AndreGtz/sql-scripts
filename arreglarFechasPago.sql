## Arreglar fechas
set @noSolicitud = 2159;#2521
set @cveContratacion = (select cveContratacion from contratacion where noSolicitud = @noSolicitud);
set @pagoFrom = 1;
set @pagoTo = 49;
select @noSolicitud,@cveContratacion,@pagoFrom,@pagoTo;

select * from planpagos where cveContratacion = @cveContratacion;
select noAportacion,fechaPago,noPago from planpagos where cveContratacion = @cveContratacion;
#arreglar fechas de pago
update planpagos set noAportacion = (noAportacion+2) where noPago>=@pagoFrom and noPago<=@pagoTo and cveContratacion = @cveContratacion;
update planpagos set fechaPago = (select fecha from quincenas where cveQuincena = planpagos.noAportacion) where cveContratacion = @cveContratacion and noPago>=@pagoFrom and noPago<=@pagoTo;
#actualizar mayor, aplicacioncob y edo_cta_cte
update mayor set fechaProg = (select fechaPago from planpagos where cveContratacion=@cveContratacion and cvePago = mayor.cvePago) where cveContratacion = @cveContratacion;
update aplicacioncob set fecha = (select fechaProg from mayor where cveContratacion=@cveContratacion and cveMayor = aplicacioncob.cveMayor) where cveContratacion = @cveContratacion;
update edo_cta_cte set fecha = (select fechaProg from mayor where cveContratacion = @cveContratacion and cveMayor=edo_cta_cte.cveMayor) where cveContratacion = @cveContratacion and cveMayor!=0;
update edo_cta_cte set fecha = (select fecha from cobranza where cveContratacion = @cveContratacion and cveCobranza = edo_cta_cte.cveCobranza) where cveContratacion = @cveContratacion and cveCobranza!=0;
#############################################################################################################################
