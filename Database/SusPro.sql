---------------------
-- FUNCIONES 
---------------------

--Función Edad

drop function if exists getEdad
go
create function getEdad (@fnac date)
returns int
AS
BEGIN
	return  DATEDIFF(HOUR, @fnac, getdate()) / 8766
END
go

--Codigo de Persona

drop function if exists getCodigoPersona
go
create function getCodigoPersona()
returns char(8)
as
BEGIN
	declare @cod char(8), @n int
	set @n = (select COUNT(*) from Persona )
	if @n >= 1
		begin 
			set @cod = (select top 1 PersonaID from Persona order by PersonaID DESC)
			set @n = SUBSTRING(@cod, 4,7)
			set @n = @n + 1
			set @cod = 'PR-' + REPLICATE(0,5 - LEN(@n)) + TRIM(str(@n))
		end
	else 
		begin
			set  @cod = 'PR-00001'
		end

	return @cod
END
go

--Codigo idSuscripcion
drop function if exists getidsuscripcion
go
Create function getIdSuscripcion()
returns char(8)
as
begin
	 declare @cod char (8) ,@n int
	 set @n = (select count(*) from Suscripcion)
	 if @n = 1
		begin
			set @cod = (select top 1 SuscripcionID from Suscripcion order by SuscripcionID desc)
			set @n = (SUBSTRING(@cod,4,7))
			set @n = @n + 1
			set @cod= 'SU-' + REPLICATE(0,5 -len(@n)) + trim(str(@n))
		end
	else
		begin
		set @cod = 'SU-00001'
	end

		return @cod
end
go
------------------------------------------------
-- PROCEDIMIENTOS ALMACENADOS PERSONA , USUARIO
------------------------------------------------
--REGISTRO

drop proc if exists sp_CrearUsuario
go
create proc sp_CrearUsuario
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
		declare @edad int, @perID char(8)
		declare @llave varchar(128)
		set @llave = 'FrAseSecRetA2020SeNAti'
		set  @edad = dbo.getEdad(@fnac)
		set @perID = dbo.getCodigoPersona()
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
				set @msg = 'Contraseña incorrecto, no se registro'
				return
			end
		
			insert Persona (PersonaID,Nombre,Apellido,FechaNacimiento,Edad,Telefono,Correo,Pais) 
					values(@perID,@nom, @ape,@fnac,@edad,@tef,@cor,@pais)
			insert Usuario (Nombre,Contraseña,idPersona)
					values(@user,ENCRYPTBYPASSPHRASE(@llave,@pass),@perID)
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
				set @msg = 'Contraseña incorrecto, no se registro'
				return
			end
		
			Update Persona set	PersonaID = @perID, Nombre = @nom, 
								Apellido=@ape,FechaNacimiento =@fnac,
								Edad =@edad,Telefono = @tef,
								Correo = @cor,Pais =@pais where PersonaID = @perID
			Update Usuario set idPersona=@perID, Nombre = @user , 
								Contraseña = ENCRYPTBYPASSPHRASE(@llave,@pass) 
								where idPersona = @perID
			set @msg = 'Registro Actualizado'
	END TRY
	BEGIN CATCH
		set @msg = ERROR_MESSAGE()
	END CATCH
end
go

--ELIMINAR 



drop proc if exists sp_EliminarUsuario
go
create proc sp_EliminarUsuario
	@perID char(8),
	
	@msg varchar(100)out

as
begin 
	BEGIN TRY

		--Validaciones

		if LEN(@perID) = 0 or @perID is null
			begin
				set @msg = 'Codigo incorrecto, no se elimino'
				return
			end
		else if not exists(select * from Usuario, Persona where idPersona = @perID and PersonaID = @perID)
			begin
				set @msg = 'No existe el usuario '
				return
			end

			delete from Usuario where idPersona = @perID
			delete from Persona where PersonaID = @perID
			set @msg = 'Registro Eliminado'
			
	END TRY

	BEGIN CATCH
		set @msg = ERROR_MESSAGE()
	END CATCH

end
go

-------------------------------------------
-- PROCEDIMIENTOS ALMACENADOS PROVEEDORES
-------------------------------------------

--Registro
drop procedure if exists sp_InsertarProveedor
go
create proc sp_InsertarProveedor
    @nom varchar(100),
    @cat varchar(100),
    @nomusu varchar(100),
    @msg varchar(100) out
AS
BEGIN
    IF LEN(@nom) = 0 or @nom is null
            begin
                 set @msg = 'El campo Nombre se encuentra vacio'
                 return
            end
	else if exists (select * from Usuario where Nombre = @nom)
            begin
                 set @msg = 'El Nombre ya existe'
                 return
            end
    else if LEN(@cat) = 0 or @cat is null
            begin
                 set @msg = 'Debe ingresar una categoria por favor'
                 return
            end
    else if LEN(@nomusu) = 0 or @nomusu is null
            begin
                 set @msg = 'Debe ingresar su nombre de usuario'
                 return
            end
    BEGIN TRY
        INSERT Proveedor Values(@nom, @cat, @nomusu)
        set @msg = 'Registro insertado'
    END TRY
    BEGIN CATCH
        set @msg = 'Mensaje de error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

--Procedimiento proveedores ACTULIZAR

drop procedure if exists sp_ActualizarProveedor
go
create proc sp_ActualizarProveedor
    @nom varchar(100),
    @cat varchar(100),
    @msg varchar(100) out
AS
BEGIN
    IF LEN(@nom) = 0 or @nom is null
            begin
                 set @msg = 'Debe ingresar un Nombre'
                 return
            end
    ELSE IF NOT EXISTS(select * from Proveedor where Nombre = @nom)
            begin
                 set @msg = 'El Proveedor indicado no existe'
                 return
            end
    else if LEN(@cat) = 0 or @cat is null
            begin
                 set @msg = 'El campo categoria no puede quedar vacio'
                 return
            end
    BEGIN TRY
        UPDATE Proveedor SET
        Categoria = @cat
        WHERE Nombre = @nom
        set @msg = 'Registro Actualizado'
    END TRY
    BEGIN CATCH
        set @msg = 'Mensaje de error: ' + ERROR_MESSAGE()
        print @msg
    END CATCH
END
GO

--ELIMINAR PROVEEDOR

drop procedure if exists sp_EliminarProveedor
go
create proc sp_EliminarProveedor
    @nom varchar(100),
    @msg varchar(100) out
AS
BEGIN
    IF LEN(@nom) = 0 or @nom is null
            begin
                 set @msg = 'Debe ingresar un Nombre'
                 return
            end
    ELSE IF NOT EXISTS(select * from Proveedor where Nombre = @nom)
            begin
                 set @msg = 'El Proveedor indicado no existe'
                 return
            end
    BEGIN TRY
        DELETE FROM Proveedor WHERE Nombre = @nom
    END TRY
    BEGIN CATCH
        set @msg = 'Mensaje de error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

--BUSCAR PROVEEDOR

drop procedure if exists sp_BuscarProveedor
go
create proc sp_BuscarProveedor
    @nom varchar(100),
    @msg varchar(100) out
AS
BEGIN
    IF LEN(@nom) = 0 or @nom is null
            begin
                 set @msg = 'Debe ingresar un Nombre'
                 return
            end
    ELSE IF NOT EXISTS(select * from Proveedor where Nombre = @nom)
            begin
                 set @msg = 'El Proveedor indicado no existe'
                 return
            end
    BEGIN TRY
        SELECT * FROM Proveedor WHERE Nombre = @nom
    END TRY
    BEGIN CATCH
        set @msg = 'Mensaje de error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

--FILTRAR PROVEEDOR

drop procedure if exists sp_FiltrarProveedor
go
create proc sp_FiltrarProveedor
    @cat varchar(100),
    @msg varchar(100) out
AS
BEGIN
    IF LEN(@cat) = 0 or @cat is null
            begin
                 set @msg = 'Debe seleccionar una categoria'
                 return
            end
    ELSE IF NOT EXISTS(select * from Proveedor where Categoria = @cat)
            begin
                 set @msg = 'No existe la categoria indicada'
                 return
            end
    BEGIN TRY
        SELECT * FROM Proveedor WHERE Categoria = @cat
    END TRY
    BEGIN CATCH
        set @msg = 'Mensaje de error: ' + ERROR_MESSAGE()
    END CATCH
END
go
 
-------------------------------------------
-- PROCEDIMIENTOS ALMACENADOS SUSCRIPCIÓN
-------------------------------------------

drop procedure if exists SP_Registrar_suscripcion
go
create procedure SP_Registrar_suscripcion
	@Ciclo varchar(100),
	@FechaPago date ,
	@Recordatorio varchar(100),
	@Imp decimal(7,1),
	@TipoMoneda varchar(100),
	@nomUser varchar(100),
	@nompro varchar(100),

	@msg varchar(100) out
	
as
begin
	declare @suscripID char(8)
	set @suscripID = dbo.getIdSuscripcion()

	IF LEN(@Ciclo) = 0 or @Ciclo is null
		begin
			set @msg = 'El seleccione sus ciclo'
			return
		end
	else if LEN(@FechaPago) = 0 or @FechaPago is null
		begin
			set @msg = 'Debe ingresar su Fecha de Pago'
			return
		end
	else if LEN(@Recordatorio) = 0 or @Recordatorio is null
		begin
			set @msg = 'Debe ingresar su Tipo de moneda'
			return
		end
	else if LEN(@Imp) = 0 or @Imp is null
		begin
			set @msg = 'Debe Seleccionar su importe'
			return
		end
	else if LEN(@TipoMoneda) = 0 or @TipoMoneda is null
		begin
			set @msg = 'Debe ingresar su Tipo de moneda'
		return
	end
	BEGIN TRY
		INSERT Suscripcion(SuscripcionID,Ciclo,FechaPago,Recordatorio,Importe,TipoMoneda,nombreUsuario,nombreProveedor) Values(@suscripID,@Ciclo,@FechaPago,@Recordatorio,@Imp,@TipoMoneda,@nomUser,@nompro)
		set @msg = 'Registro completado'
	END TRY
	BEGIN CATCH
		set @msg = 'Error: ' + ERROR_MESSAGE()
	END CATCH
END
go

--ACTUALIZAR

drop procedure if exists SP_Actualizar_suscripcion
go
Create procedure SP_Actualizar_suscripcion
	@suscripID char(8),
	@Ciclo varchar(100),
	@FechaPago date ,
	@Recordatorio varchar(100),
	@Imp decimal(7,1),
	@TipoMoneda varchar(100),
	@nomUser varchar(100),
	@nompro varchar(100),

	@msg varchar(100)out 
AS
BEGIN

	IF LEN(@Ciclo) = 0 or @Ciclo is null
		begin
			set @msg = 'El seleccione sus ciclo'
			return
		end
	else if LEN(@FechaPago) = 0 or @FechaPago is null
		begin
			set @msg = 'Debe ingresar una Fecha'
			return
		end
	else if LEN(@Recordatorio) = 0 or @Recordatorio is null
		begin
			set @msg = 'Debe ingresar su recordatorio'
			return
		end
	else if LEN(@Imp) = 0 or @Imp is null
		begin
			set @msg = 'Debe ingresar su Importe'
			return
		end
	else if LEN(@TipoMoneda) = 0 or @TipoMoneda is null
		begin
			set @msg = 'Debe ingresar su Tipo de moneda'
			return
		end
	BEGIN TRY
		UPDATE  Suscripcion SET SuscripcionID = @suscripID, Ciclo= @Ciclo,FechaPago = @FechaPago,
				Recordatorio = @Recordatorio, Importe=@Imp,
				TipoMoneda =@TipoMoneda, nombreUsuario=@nomUser,
				nombreProveedor = @nompro where SuscripcionID = @suscripID
	END TRY
	BEGIN CATCH
		set @msg = 'Error: ' + ERROR_MESSAGE()
	END CATCH
END
GO

--ELIMINAR

drop procedure if exists sp_Eliminar_suscripcion
go
create proc sp_Eliminar_suscripcion
@Sus varchar(100),
@msg varchar(100) out
AS
BEGIN
	IF LEN( @Sus) = 0 or @Sus is null
		begin
			set @msg = 'Ingresar el nombre de la suscripcion'
			return
		end
	ELSE IF NOT EXISTS(select * from Proveedor where Nombre = @Sus)
		begin
			set @msg = 'La suscripcion no existe'
			return
		end
	BEGIN TRY
		DELETE FROM Suscripcion WHERE SuscripcionID = @Sus
	END TRY
	BEGIN CATCH
		set @msg = 'Error: ' + ERROR_MESSAGE()
	END CATCH
END
GO