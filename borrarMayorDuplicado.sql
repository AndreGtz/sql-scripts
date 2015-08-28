delete from mayor where cveMayor in (
select * from (
select count(*) as cn,cveContratacion,max(cveMayor) as mx from mayor where fechaProg='2015-08-15' group by cveContratacion) as x
where cn>1);
