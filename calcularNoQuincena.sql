select 
DATE_FORMAT(planpagos.fechaPago,'%m')*2+ROUND((DATE_FORMAT(planpagos.fechaPago,'%d')/15)-2)  as quincena
from planpagos;