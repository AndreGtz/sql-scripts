## Arreglar fechas
set @noSolicitud = 2045;#2521
set @cveContratacion = (select cveContratacion from contratacion where noSolicitud = @noSolicitud);
set @pagoFrom = 1;
set @pagoTo = 49;
select @noSolicitud,@cveContratacion,@pagoFrom,@pagoTo;

select * from planpagos where cveContratacion = @cveContratacion;
select noAportacion,fechaPago,noPago from planpagos where cveContratacion = @cveContratacion;
#arreglar fechas de pago
update planpagos set noAportacion = (noAportacion+2) where noPago>=@pagoFrom and noPago<=@pagoTo and cveContratacion = @cveContratacion;
update planpagos set fechaPago = (select fecha from quincenas where cveQuincena = planpagos.noAportacion) where cveContratacion = @cveContratacion and noPago>=@pagoFrom and noPago<=@pagoTo;

