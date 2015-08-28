############################################################################################################################
#Pagar multiples pagos.
set @noSolicitud = 3544;#2521
set @cveContratacion = (select cveContratacion from contratacion where noSolicitud = @noSolicitud);
set @pagoFrom = 9;
set @pagoTo = 9;
set @monto = (select monto from cobranza where cveContratacion = @cveContratacion limit 0,1);
set @mAplicado = (select mAplicado from cobranza where cveContratacion = @cveContratacion limit 0,1);
select @noSolicitud,@cveContratacion,@pagoFrom,@pagoTo,@monto,@mAplicado;
#agregar pagos a mayor
update mayor set haber = debe, statusMayor = 4, abCapital = capital, abInteres = interes, abIva = iva 
where cveContratacion=@cveContratacion and 
cvePago in (select cvePago from planpagos where cveContratacion = @cveContratacion and noPago>=@pagoFrom and noPago<=@pagoTo);

#Insertar a cobranza
insert into cobranza (fecha,monto,mEfectivo,cveContacto,tipoPago,statusPago,cveUsrReg,imprimirRecibo,mAplicado,origen,cveMoneda,cveConvenio,noPago,cveContratacion)
select distinct     fechaPago,@monto,@monto,cveContacto,       1,       1,        135,      1,       @mAplicado,1,  1,        cveConvenio,noAportacion,cveContratacion 
from planpagos where cveContratacion = @cveContratacion and noPago >= @pagoFrom and noPago<=@pagoTo;

#Insertar en aplicacioncob*
insert into aplicacioncob (cveConvenio,cveContacto,cveCobranza,cveMayor,fecha,hora,cveConcepto,cveContratacion,capital,interes,iva)
select distinct planpagos.cveConvenio,planpagos.cveContacto,cveCobranza,cveMayor,'2015-04-29','00:00:00',1,planpagos.cveContratacion,mayor.capital,mayor.interes,mayor.iva
from planpagos inner join cobranza 
on (planpagos.fechaPago = cobranza.fecha and planpagos.cveContratacion = cobranza.cveContratacion)
inner join mayor on planpagos.cvePago = mayor.cvePago
where planpagos.cveContratacion = @cveContratacion 
and cobranza.cveCobranza not in (select cveCobranza from aplicacioncob where cveContratacion = @cveContratacion);

#Insertar en edo_cta_cte
insert into edo_cta_cte (tipoMov,cveMayor,cveCobranza,fecha,hora,cveContacto,cveConvenio,noPago,cveContratacion)
select distinct 5,0,cveCobranza,fecha,'00:00:00',cveContacto,cveConvenio,noPago,cveContratacion 
from cobranza 
where cveContratacion = @cveContratacion
and cveCobranza not in (select cveCobranza from edo_cta_cte where cveContratacion = @cveContratacion);

#Update planpagos status a 1 (pagado)
update planpagos set status = 1 where cveContratacion = @cveContratacion and noPago >= @pagoFrom and noPago <= @pagoTo;

##fin
#################################################################################################################################

