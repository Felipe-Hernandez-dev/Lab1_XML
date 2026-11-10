-- F5 (parte 1): Registrar el XSD y crear la tabla basada en el esquema
SET SERVEROUTPUT ON

-- Limpieza previa para poder repetir el script
BEGIN EXECUTE IMMEDIATE 'DROP TABLE departamentos_xml PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  DBMS_XMLSCHEMA.DELETESCHEMA('http://localhost/departamentos.xsd',
                              DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE);
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Registro del esquema (el XSD va dentro del script)
BEGIN
  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    schemaurl => 'http://localhost/departamentos.xsd',
    schemadoc => XMLTYPE(q'~<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
  <xs:simpleType name="EmailTipo">
    <xs:restriction base="xs:string">
      <xs:pattern value="[A-Z]+"/>
      <xs:maxLength value="25"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="SalarioTipo">
    <xs:restriction base="xs:decimal">
      <xs:minExclusive value="0"/>
      <xs:totalDigits value="8"/>
      <xs:fractionDigits value="2"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:complexType name="EmpleadoTipo">
    <xs:sequence>
      <xs:element name="nombre" type="xs:string"/>
      <xs:element name="apellido" type="xs:string"/>
      <xs:element name="email" type="EmailTipo"/>
      <xs:element name="salario" type="SalarioTipo"/>
      <xs:element name="fecha_ingreso" type="xs:date"/>
    </xs:sequence>
    <xs:attribute name="id" type="xs:positiveInteger" use="required"/>
  </xs:complexType>
  <xs:complexType name="DepartamentoTipo">
    <xs:sequence>
      <xs:element name="empleado" type="EmpleadoTipo" minOccurs="1" maxOccurs="unbounded"/>
    </xs:sequence>
    <xs:attribute name="id" type="xs:positiveInteger" use="required"/>
    <xs:attribute name="nombre" type="xs:string" use="required"/>
  </xs:complexType>
  <xs:element name="departamentos">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="departamento" type="DepartamentoTipo" minOccurs="1" maxOccurs="unbounded"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>~'),
    local     => TRUE,
    gentypes  => FALSE,
    gentables => FALSE);
  DBMS_OUTPUT.PUT_LINE('Esquema registrado correctamente.');
END;
/

-- Tabla que solo acepta XML del esquema registrado
CREATE TABLE departamentos_xml OF XMLTYPE
  XMLTYPE STORE AS BINARY XML
  XMLSCHEMA "http://localhost/departamentos.xsd" ELEMENT "departamentos";

-- Regla que exige que cada documento cumpla el XSD completo
ALTER TABLE departamentos_xml
  ADD CONSTRAINT ck_departamentos_valido CHECK (XMLISVALID(OBJECT_VALUE) = 1);

-- Comprobar que el esquema quedó registrado
SELECT schema_url FROM user_xml_schemas;