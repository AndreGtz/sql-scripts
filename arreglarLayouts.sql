##########################
# Arreglar layouts       #
##########################


#variables
set @noSolicitud = 6579;#2521
set @cveContratacion = (select cveContratacion from contratacion where noSolicitud = @noSolicitud);


# cambiar manualmente en planpagos las cveLayout
select * from planpagos where cveContratacion = @cveContratacion;


# actualizar las tablas cobranza,pagoslayout
update pagoslayout set cveLayout = 
(select planpagos.cveLayout from planpagos 
	where planpagos.cveContratacion = @cveContratacion 
		and planpagos.statusRegistro = 1
		and planpagos.noPago = pagoslayout.noPago)  
where cveContratacion = @cveContratacion;
update pagoslayout set cveLayout = 
(select planpagos.cveLayout from planpagos 
	where planpagos.cveContratacion = @cveContratacion 
		and planpagos.statusRegistro = 1
		and planpagos.noPago = pagoslayout.noPago)  
where cveContratacion = @cveContratacion;


#si hay registros en planpagos que no hay en pagoslayout insertarlos
insert into pagoslayout (cvePago,cveContratacion,cveConcepto,interes,cveUsrReg,fechaReg,status,cveConvenio,cveContacto,saldo,iva,noAportacion,tipoAportacion,aplicaInteres,statusRegistro,montoProg,devengado,fechaDev,hrDev,fechaPago,capital,cantidadPagada,saldoFinalTotal,tipoTransaccion,noPago,cveLayout,observaciones)
(select cvePago,cveContratacion,cveConcepto,interes,cveUsrReg,fechaReg,status,cveConvenio,cveContacto,saldo,iva,noAportacion,tipoAportacion,aplicaInteres,statusRegistro,montoProg,devengado,fechaDev,hrDev,fechaPago,capital,cantidadPagada,saldoFinalTotal,tipoTransaccion,noPago,cveLayout,observaciones 
from planpagos 
	where cveContratacion = @cveContratacion 
		and noPago!=0 
        and statusRegistro = 1 
        and cveLayout!=0 
        and cvePago not in (select cvePago from pagoslayout where cveContratacion  = @cveContratacion));