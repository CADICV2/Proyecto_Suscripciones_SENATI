use master
go

drop database if exists sistema_suscripcion
go
create database sistema_suscripcion
go
use sistema_suscripcion
go

drop table if exists Persona
go
create table Persona(
	PersonaID char(8) not null,
	Nombre varchar(100) not null,
	Apellido varchar(100) not null,
	FechaNacimiento date not null,
	Edad int not null,
	Telefono char(9),
	Correo varchar(100) not null,
	Pais varchar(100) not null
)
go



drop table if exists Usuario
go
create table Usuario(
	Nombre varchar(100) not null,
	Contrase�a varbinary(8000) not null,
	Estado bit not null,
	FechaRegistro date not null,
	FechaBaja date,
	idPersona char(8) not null
)
go

drop table if exists Proveedor
go
create table Proveedor(
	Nombre varchar(100) not null,
	Categoria varchar(100) not null,
	nombreUsuario varchar(100) not null
)
go

drop table if exists Suscripcion
go
create table Suscripcion(
	SuscripcionID char(8) not null,
	Ciclo varchar(100) not null,
	FechaSuscripcion date not null,
	FechaPago date not null,
	Recordatorio varchar(100) not null,
	Importe decimal(7,2) not null, 
	TipoMoneda varchar(100) not null,
	nombreUsuario varchar(100) not null,
	nombreProveedor varchar(100) not null
)
go

------------------------------
--	RESTRICCI�N PRIMARY KEY
------------------------------

alter table Persona
	add constraint PK_Persona_Id primary key (PersonaID)
go

alter table Usuario
	add constraint PK_Usuario_Nombre primary key (Nombre)
go

alter table Proveedor
	add constraint PK_Proveedor_Nombre primary key (Nombre)
go

alter table Suscripcion
	add constraint PK_Suscripcion_Id primary key (SuscripcionID)
go

------------------------------
--	RESTRICCI�N FOREING KEY
------------------------------
alter table Usuario
	add constraint FK_Usuario_idPersona Foreign key (idPersona)
	references Persona(PersonaID)
go
alter table Proveedor
	add constraint FK_Proveedor_NomUsuario Foreign key(nombreUsuario)
	references Usuario(Nombre)
go


alter table Suscripcion
	add Constraint FK_Suscripcion_NomUsuario Foreign key(nombreUsuario )
	references Usuario(Nombre)
go

alter table Suscripcion
	add Constraint FK_Suscripcion_NomProveedor Foreign key(nombreProveedor)
	references Proveedor(Nombre)
go
------------------------------
--	RESTRICCI�N UNIQUE
------------------------------

alter table Persona
	add constraint UK_Persona_Correo unique (Correo)
Go


alter table Persona
	add constraint UK_Persona_Telefono unique (Telefono)
Go

--Restricci�n unique
alter table Usuario
	add constraint UK_Usuario_idPersona unique(idPersona)
go


alter table Suscripcion 
	add constraint UK_Suscripcion_nombreProveedor unique (nombreProveedor)
go


------------------------------
--	RESTRICCI�N CHECK
------------------------------
--Tabla Persona
alter table Persona
    add constraint Ck_Persona_Fnac check (FechaNacimiento < getdate())
go

alter table Persona
    add constraint Df_Persona_Edad check (Edad >= 18)
go

alter table Persona
    add constraint Ck_Persona_Correo check (Correo like '%@%.[A-Z][A-Z]' or Correo like '%@%.[A-Z][A-Z][A-Z]' or Correo like '%@%.[A-Z][A-Z][A-Z].[A-Z][A-Z]')
go


--Tabla Usuario

alter table Usuario
    add constraint Ck_Usuario_Estado check(Estado = 1 or Estado = 0)
go

alter table Usuario
    add constraint Ck_Usuario_FechaRegistro check (FechaRegistro <= getdate())
go

alter table Usuario
    add constraint Ck_Usuario_FechaBaja check (FechaBaja > FechaRegistro)
go

--Tabla Suscripcion

alter table Suscripcion
    add constraint Ck_Suscripcion_Fecha check (FechaSuscripcion <= getdate())
go

alter table Suscripcion
    add constraint Ck_Suscripcion_FechaPago check (FechaPago > FechaSuscripcion)
go


alter table Suscripcion
	add constraint Ck_Suscripcion_TipoMoneda check (TipoMoneda = 'Soles' or TipoMoneda = 'Dolares' or TipoMoneda = 'Euros')
go

alter table Suscripcion
	add constraint Ck_Suscripcion_Ciclo check (Ciclo = 'Semanal' or Ciclo = 'Mensual' or Ciclo = 'Quincenal')
go
------------------------------
--	RESTRICCI�N DEFAULT
------------------------------

--Tabla Persona
alter table Persona
    add constraint Df_Persona_Pais Default 'Per�' for Pais
go

--Tabla Usuario
alter table Usuario
    add constraint Df_UsuarioEstado Default 1 for Estado
go


alter table Usuario
    add constraint Df_UsuarioFechaRegistro Default getdate() for FechaRegistro
go

--Tabla Suscripcion
alter table Suscripcion
    add constraint Df_SuscripcionFecha Default getdate() for FechaSuscripcion
go
alter table Suscripcion
    add constraint Df_SuscripcionMoneda Default 'Soles' for TipoMoneda
go


--------------------------------------------------
--PROCEDIMINETOS ALMACENADOS DE PERSONA Y USUARIO
--------------------------------------------------

--REGISTRO

drop proc if exists sp_CrearUsuario
go
create proc sp_CrearUsuario
	@perID char(8),
	@nom varchar(100),
	@ape varchar(100),
	@fnac date,
	@tef char(9),
	@cor varchar(100),
	@pais varchar(100),
	@user varchar(100),
	@pass varchar(100),

	@msg varchar(100)out

as
begin 
	BEGIN TRY

		declare @edad int
		declare @llave varchar(128)
		set @llave = 'FrAseSecRetA2020SeNAti'
		set  @edad = dbo.getEdad(@fnac)
		
		--validadciones
		if LEN(@nom) = 0 or @nom = null
		begin
			set @msg = 'Nombre incorrecto, no se registro'
			return
		end
		else if LEN(@ape) = 0 or @ape = null
			begin
				set @msg = 'Apellido incorrecto, no se registro'
				return
			end
		else if LEN(@fnac) = 0 or @fnac = null
			begin
				set @msg = 'Fecha de Nacimiento incorrecto, no se registro'
				return
			end
		else if LEN(@edad) = 0 or @edad = null
			begin
				set @msg = 'Edad incorrecto, no se registro'
				return
			end
		else if @edad <= 17 
			begin
				set @msg = 'Eres menor de edad, no puedes registrarte'
				return
			end
		else if LEN(@tef) = 0
			begin
				set @msg = 'Telefono vacio, no se registro'
				return
			end
		else if LEN(@cor) = 0 or @cor = null
			begin
				set @msg = 'Correo incorrecto, no se registro'
				return
			end
		else if exists( select Correo from Persona where Correo = @cor)
			begin
				set @msg = 'El Correo ya existe'
				return
			end
		else if LEN(@pais) = 0 or @pais = null
			begin
				set @msg = 'Pais incorrecto, no se registro'
				return
			end
		--Tabla usuario
		else if LEN(@user) = 0 or @user = null
			begin
				set @msg = 'Nombre de Usuario incorrecto, no se registro'
				return
			end
		else if LEN(@pass) = 0 or @pass = null
			begin
				set @msg = 'Contrase�a incorrecto, no se registro'
				return
			end
		
			insert Persona (PersonaID,Nombre,Apellido,FechaNacimiento,Edad,Telefono,Correo,Pais) values(@perID,@nom, @ape,@fnac,@edad,@tef,@cor,@pais)
			insert Usuario (Nombre,Contrase�a,idPersona)values(@user,ENCRYPTBYPASSPHRASE(@llave,@pass),@perID)
			set @msg = 'Registro Insertado'
			
	END TRY

	BEGIN CATCH
		set @msg = ERROR_MESSAGE()
	END CATCH

end
go

--ACTUALIZAR

drop proc if exists sp_ActualizarUsuario
go
create proc sp_ActualizarUsuario
	@perID char(8),
	@nom varchar(100),
	@ape varchar(100),
	@fnac date,
	@tef char(9),
	@cor varchar(100),
	@pais varchar(100),
	@user varchar(100),
	@pass varchar(100),

	@msg varchar(100)out

as
begin 
	BEGIN TRY

		declare @edad int, @llave varchar(128)
		set  @edad = dbo.getEdad(@fnac)
		set @llave = 'FrAseSecRetA2020SeNAti'
		
		--validadciones
		if LEN(@nom) = 0 or @nom = null
		begin
			set @msg = 'Nombre incorrecto, no se registro'
			return
		end
		else if LEN(@ape) = 0 or @ape = null
			begin
				set @msg = 'Apellido incorrecto, no se registro'
				return
			end
		else if LEN(@fnac) = 0 or @fnac = null
			begin
				set @msg = 'Fecha de Nacimiento incorrecto, no se registro'
				return
			end
		else if LEN(@edad) = 0 or @edad = null
			begin
				set @msg = 'Edad incorrecto, no se registro'
				return
			end
		else if @edad <= 17 
			begin
				set @msg = 'Eres menor de edad, no puedes registrarte'
				return
			end
		else if LEN(@cor) = 0 or @cor = null
			begin
				set @msg = 'Correo incorrecto, no se registro'
				return
			end
		else if LEN(@pais) = 0 or @pais = null
			begin
				set @msg = 'Pais incorrecto, no se registro'
				return
			end
		--Tabla usuario
		else if LEN(@user) = 0 or @user = null
			begin
				set @msg = 'Nombre de Usuario incorrecto, no se registro'
				return
			end
		else if LEN(@pass) = 0 or @pass = null
			begin
				set @msg = 'Contrase�a incorrecto, no se registro'
				return
			end
		
			Update Persona set PersonaID = @perID, Nombre = @nom, Apellido=@ape,FechaNacimiento =@fnac,Edad =@edad,Telefono = @tef,Correo = @cor,Pais =@pais where PersonaID = @perID
			Update Usuario set idPersona=@perID, Nombre = @user , Contrase�a = ENCRYPTBYPASSPHRASE(@llave,@pass) where idPersona = @perID
			set @msg = 'Registro Actualizado'
			
	END TRY

	BEGIN CATCH
		set @msg = ERROR_MESSAGE()
	END CATCH

end
go



 