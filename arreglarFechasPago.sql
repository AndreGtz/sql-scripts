select noAportacion,fechaPago,noPago from planpagos where cveContratacion = @cveContratacion;
#arreglar fechas de pago
update planpagos set noAportacion = (noAportacion-29) where noPago>=10 and cveContratacion = @cveContratacion;
update planpagos set fechaPago = (select fecha from quincenas where cveQuincena = planpagos.noAportacion) where cveContratacion = @cveContratacion 
;
