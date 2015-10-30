DROP PROCEDURE IF EXISTS recorreFechas;
DELIMITER //
CREATE DEFINER=`PactoERP`@`%` PROCEDURE recorreFechas(_cveContratacionVal LONG)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	BEGIN
		ROLLBACK;
		SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
	END;

	START TRANSACTION;
	#Saco el no de aportacion de la ultima quincena pagada
	set @maxPagado = (select max(noAportacion) from planpagos
						where planpagos.fechaPago>'2014-01-01' 
							and planpagos.statusRegistro=1 
							and planpagos.status=1 
							and planpagos.cveContratacion = _cveContratacionVal
							and planpagos.cveConvenio in (select cveConvenio from convenio where company_type = 'PRIVATE'));
	#Saco el no de aportacion de la primer quincena no pagada
	set @minNoPagado = (select min(noAportacion) from planpagos 
							where planpagos.fechaPago>'2014-01-01'
								and planpagos.status = 0
								and planpagos.statusRegistro=1 
								and planpagos.cveContratacion = _cveContratacionVal
								and planpagos.cveConvenio in (select cveConvenio from convenio where company_type = 'PRIVATE'));
	
    set @noPago = (select min(noPago) from planpagos 
							where planpagos.fechaPago>'2014-01-01'
								and planpagos.status = 0
								and planpagos.statusRegistro=1 
								and planpagos.cveContratacion = _cveContratacionVal
								and planpagos.cveConvenio in (select cveConvenio from convenio where company_type = 'PRIVATE'));
    
	#Resto la diferencia entre quincena y quinenca
    set @dif = abs(@minNoPagado-@maxPagado)-1;
    
    #Actualizo el valor de todos los pagos mayores o iguales a @minNoPagado con los valores sucesivos
    update planpagos set noAportacion = (noAportacion-@dif) where cveContratacion=_cveContratacionVal and noPago>=@noPago;
    
    #Actualizar valor de fechaPago
    update planpagos set fechaPago = (select fecha from quincenas where cveQuincena = planpagos.noAportacion) where cveContratacion = _cveContratacionVal and noPago>=@noPago;
    
	COMMIT;

END

//
DELIMITER ;

DROP PROCEDURE IF EXISTS arreglarFechasCorporativo;
DELIMITER //
CREATE DEFINER=`PactoERP`@`%` PROCEDURE arreglarFechasCorporativo()
BEGIN
	DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE _cveContratacion BIGINT UNSIGNED;
	DECLARE cur CURSOR FOR SELECT cveContratacion from planpagos
	where planpagos.fechaPago>'2014-01-01'
		and planpagos.status = 0
        and planpagos.statusRegistro=1 
        and planpagos.cveContratacion in (select cveContratacion from planpagos where planpagos.fechaPago>'2014-01-01' and planpagos.status = 1 and planpagos.statusRegistro=1  and planpagos.cveContratacion in (select cveContratacion from contratacion) and planpagos.cveConvenio in (select cveConvenio from convenio where company_type = 'PRIVATE') group by cveContratacion)
        and planpagos.cveConvenio in (select cveConvenio from convenio where company_type = 'PRIVATE')
        group by cveContratacion;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done := TRUE;    
        
	
	OPEN cur;
    testLoop: LOOP
		FETCH cur INTO _cveContratacion;
        IF done THEN
			LEAVE testLoop;
		END IF;
        CALL recorreFechas(_cveContratacion);
    END LOOP testLoop;
    CLOSE cur;
END
//
DELIMITER ;
