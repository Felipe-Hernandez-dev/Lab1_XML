-- F5 (parte 3): Inserción que NO cumple el esquema (salario negativo)
INSERT INTO departamentos_xml VALUES (XMLTYPE('
<departamentos xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xsi:noNamespaceSchemaLocation="http://localhost/departamentos.xsd">
  <departamento id="10" nombre="Administration">
    <empleado id="200">
      <nombre>Jennifer</nombre>
      <apellido>Whalen</apellido>
      <email>JWHALEN</email>
      <salario>-500</salario>
      <fecha_ingreso>2013-09-17</fecha_ingreso>
    </empleado>
  </departamento>
</departamentos>'));

SELECT COUNT(*) AS filas_tras_invalida FROM departamentos_xml;