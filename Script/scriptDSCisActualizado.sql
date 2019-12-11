USE [master]
GO
/****** Object:  Database [DSCIS]    Script Date: 11-12-2019 12:59:46 ******/
CREATE DATABASE [DSCIS]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DSCIS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\HOLA1234.mdf' , SIZE = 6144KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'DSCIS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\HOLA1234_log.ldf' , SIZE = 6272KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [DSCIS] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DSCIS].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [DSCIS] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DSCIS] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DSCIS] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DSCIS] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DSCIS] SET ARITHABORT OFF 
GO
ALTER DATABASE [DSCIS] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [DSCIS] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [DSCIS] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DSCIS] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DSCIS] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DSCIS] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DSCIS] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DSCIS] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DSCIS] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DSCIS] SET  DISABLE_BROKER 
GO
ALTER DATABASE [DSCIS] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DSCIS] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [DSCIS] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [DSCIS] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [DSCIS] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DSCIS] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [DSCIS] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [DSCIS] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [DSCIS] SET  MULTI_USER 
GO
ALTER DATABASE [DSCIS] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [DSCIS] SET DB_CHAINING OFF 
GO
ALTER DATABASE [DSCIS] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [DSCIS] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [DSCIS] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'DSCIS', N'ON'
GO
ALTER DATABASE [DSCIS] SET QUERY_STORE = OFF
GO
USE [DSCIS]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
USE [DSCIS]
GO
/****** Object:  UserDefinedFunction [dbo].[RESPALDOREAL]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[RESPALDOREAL](
@ano varchar(20),
@nivel varchar(10),
@fechaDesde varchar(15), 
@fechaHasta varchar(15),
@CCosto varchar(15),
@bd varchar(20),
@nivelEERR int
)
returns int
as
BEGIN
declare @xvalor float(50)
declare @xvalorSuma int
declare @existeDist int
declare @porcentaje float
declare @existeSuma int
declare @primerNivel int
declare @limpia int

set @existeDist = 
(
	--select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] 
	where codiCC = @CCosto+'-000' 
	AND idCuenta =  @nivel 
	AND valor <> '100' 
	AND valor <> '0' 
	AND BDSession = @bd 
	and ano = @ano
)
IF(@existeDist > 0)
	BEGIN
		--set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel)
		--select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '20-001' AND idCuenta = '4'
		--set @xvalor = ((@xvalor*@porcentaje)/100)	
		IF(@nivelEERR = 1)
			BEGIN
				--set @xvalor = '1'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd  and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							
							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd
							and movim.CcCod like '12-%'
	)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
				--set @xvalor = (@xvalor *-1)
			END
		IF(@nivelEERR = 2)
			BEGIN
				--set @xvalor = '2'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							
							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd
			    			and movim.CcCod like '11-%'
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)
				set @limpia=@xvalor
				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@limpia + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 3)
			BEGIN
				--set @xvalor = '3'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							/*SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							--AND movim.ccCod = '01-001' AND cpbte.CpbEst = 'V' 
							AND movim.ccCod like '01%' AND cpbte.CpbEst = 'V'*/ 

							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
								and movim.CcCod like '01-%'
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 4)
			BEGIN
				--set @xvalor = '4'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							/*SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							--AND movim.ccCod = '01-001' AND cpbte.CpbEst = 'V'
							AND movim.ccCod like '01%' AND cpbte.CpbEst = 'V'*/

							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd

						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 5)
			BEGIN
				--set @xvalor = '5'
				
				if(@nivel=24)
				begin 
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
						)
				set @xvalor = (@xvalor*@porcentaje)


				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				end
				end
			else
				begin 
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)



				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
				end
			





				
				----IF(@nivel = 21 OR @nivel = 22 OR @nivel = 25)
				--BEGIN
				--	set @xvalor = (@xvalor *-1)
				--END
				

				IF(@nivel = 21 OR @nivel = 22 OR @nivel=24 or @nivel = 25)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
				
					END
				END

			

				IF(@nivel = 25)
				BEGIN
					declare @xvalorDebe float
					declare @xvalorHaber float


					set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
					set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
					/*
					set @xvalor = 
							(
								SELECT 
								isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
								FROM CIS.softland.cwmovim movim 
								INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
								WHERE movim.cpbano = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
									select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR
							)
					*/
					set @xvalorDebe = 
							(
								SELECT 
								isnull(sum(MovDebe),0) as resultadoSuma
								FROM CIS.softland.cwmovim movim 
								INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
								WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
												select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
							)

					
					set @xvalorHaber = 
							(
								SELECT 
								isnull(sum(MovHaber),0) as resultadoSuma
								FROM CIS.softland.cwmovim movim 
								INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
								WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
												select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
							)
					
					
					--set @xvalor = ((@xvalor*@porcentaje)/100)
					
					declare @sumaDiferencia float
					set @sumaDiferencia = (@xvalorHaber-@xvalorDebe)
					set @xvalor = ((@sumaDiferencia)*@porcentaje/100)
					--set @xvalor = '123456'



					
					
					IF(@existeSuma > 0)
					BEGIN
						declare @xvalorDebeSuma float
						declare @xvalorHaberSuma float
						set @xvalorDebeSuma = 
									(
										SELECT 
										isnull(sum(MovDebe),0) as resultadoSuma
										FROM CIS.softland.cwmovim movim 
										INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
										INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
										WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
										AND movim.pctcod collate Modern_Spanish_CI_AS IN   
										(
														select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
										) 
										and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
										--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
										AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
									)
						set @xvalorHaberSuma = 
									(
										SELECT 
										isnull(sum(MovHaber),0) as resultadoSuma
										FROM CIS.softland.cwmovim movim 
										INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
										INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
										WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
										AND movim.pctcod collate Modern_Spanish_CI_AS IN   
										(
														select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
										) 
										and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
										--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
										AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
									)
					declare @sumaDiferenciaSuma float
					set @sumaDiferenciaSuma = (@xvalorHaberSuma-@xvalorDebeSuma)

						set @xvalor = (@xvalor + @sumaDiferenciaSuma)
						
						--set @xvalor = '999999999'
					END
					




				END


				--set @xvalor = '999999999'
			END
	END
ELSE
	BEGIN
		--set @xvalor = '99999999999999'
		--select idNivel from [DSCIS].[dbo].[DS_DistribucionCC]
		
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
		set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
		set @xvalor = 
					(
						SELECT 
						isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
						FROM CIS.softland.cwmovim movim 
						INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
						INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
						WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
						AND movim.pctcod collate Modern_Spanish_CI_AS IN   
						(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
						) 
						and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
						--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
						AND movim.ccCod like ''+@CCosto+'%' AND cpbte.CpbEst = 'V'

						

					)
		set @xvalor = ((@xvalor*@porcentaje)/100)
		--set @xvalor = '777777'

	IF(@existeSuma > 0)
	BEGIN
		set @xvalorSuma = 
					(
						SELECT 
						isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
						FROM CIS.softland.cwmovim movim 
						INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
						INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
						WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
						AND movim.pctcod collate Modern_Spanish_CI_AS IN   
						(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
						) 
						and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
						--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V' 
						AND movim.ccCod like ''+@CCosto+'%' AND cpbte.CpbEst = 'V'

					)

		set @xvalor = (@xvalor + @xvalorSuma)
	END

	set @primerNivel = (select idNivel from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd  and ano = @ano)

		IF(@primerNivel = 0)
		BEGIN
			set @xvalor = (@xvalor *-1)
		END

		IF(@nivel = 25 or @nivel = 22)
		BEGIN
			set @xvalor = (@xvalor *-1)
		END

END

--select 13056852*10/100,13056852
--set @xvalor = (@xvalor)
if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnAcumulado]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnAcumulado](@ano varchar(8),@nivel varchar(4),@bd varchar(50), @fechaDesdeAcumulado varchar(20),@fechaHastaAcumulado varchar(20),@CCosto varchar(20)  )
returns varchar(18)
as
BEGIN
declare @xvalor varchar(50)

set @xvalor = 
(
	select 
	isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
	from CIS.softland.cwmovim movim 
	INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
	where cpbano = @ano
	AND movim.pctcod collate Modern_Spanish_CI_AS IN   
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
	) 
	and CpbFec  BETWEEN convert(datetime,@fechaDesdeAcumulado,103) AND convert(datetime,@fechaHastaAcumulado,103) 
	AND movim.ccCod = @CCosto
)


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnAcumuladoCIS]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnAcumuladoCIS](@ano varchar(8),@nivel varchar(4),@bd varchar(50), @fechaDesdeAcumulado varchar(20),@fechaHastaAcumulado varchar(20),@CCosto varchar(20)  )
returns varchar(18)
as
BEGIN
declare @xvalor varchar(50)

set @xvalor = 
(
	select 
	isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
	from CIS.softland.cwmovim movim 
	INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
	where cpbano = @ano
	AND movim.pctcod collate Modern_Spanish_CI_AS IN   
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
	) 
	and CpbFec  BETWEEN convert(datetime,@fechaDesdeAcumulado,103) AND convert(datetime,@fechaHastaAcumulado,103) 
	AND movim.ccCod = @CCosto
)


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnAcumuladoHORNILLAS]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnAcumuladoHORNILLAS](@ano varchar(8),@nivel varchar(4),@bd varchar(50), @fechaDesdeAcumulado varchar(20),@fechaHastaAcumulado varchar(20),@CCosto varchar(20)  )
returns varchar(18)
as
BEGIN
declare @xvalor varchar(50)

set @xvalor = 
(
	select 
	isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
	from CIS.softland.cwmovim movim 
	INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
	where cpbano = @ano
	AND movim.pctcod collate Modern_Spanish_CI_AS IN   
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
	) 
	and CpbFec  BETWEEN convert(datetime,@fechaDesdeAcumulado,103) AND convert(datetime,@fechaHastaAcumulado,103) 
	AND movim.ccCod = @CCosto
)


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnPPTO]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnPPTO](@ano varchar(20),@IDPresupuesto varchar(50),@CCosto varchar(20), @nivelCuenta varchar(20),@bd varchar(30),@mes varchar(6),@condicion int) 
returns float(50)
as
BEGIN
declare @xvalor float(50)
declare @xvalorDist float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float(50)
declare @obtengoNivel int
declare @existeSuma int


set @obtengoNivel = (select idNivel from dscis.dbo.DS_nivelesEERR where idcuenta = @nivelCuenta)

--select * from dscis.dbo.DS_AgrupacionCuentas where idNivel = '5'
--select * from dscis.dbo.DS_nivelesEERR where idcuenta = '5'

IF(@condicion = 0)
BEGIN
set @existeDist = 
(
	--select * from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '13-001' AND idCuenta =  '5' AND valor <> '100' AND valor <> '0'
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta =  @nivelCuenta AND valor <> '100' AND valor <> '0'
)
	BEGIN


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 0)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '12-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '11-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
--@nivelCuenta

				IF(@nivelCuenta = 21 OR @nivelCuenta = 22 OR @nivelCuenta = 25)
				BEGIN
					set @xvalor = (@xvalor *-1)
				END
				

				IF(@nivelCuenta = 20)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

				IF(@nivelCuenta = 24)
				BEGIN
					IF(@xvalor >0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel >= 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta )
		IF(@existeDist >= 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	


	END

END
ELSE
BEGIN
/*
set @xvalor = 
(
	SELECT 
	isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
	FROM  CIS.softland.cwpreop
	WHERE PreopAno = @ano
	AND Preop_id = @IDPresupuesto
	AND PreopCC = @CCosto
	AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
	)
	AND PreopMes BETWEEN '01' AND @mes
)

set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto and idCuenta = @nivelCuenta)

set @xvalor = ((@xvalor * @porcentaje)/100)
*/

IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '12-001'
					AND PreopCC like '12%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			--set @xvalor = '123465798'

			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '11-001'
					AND PreopCC like '11%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	IF(@obtengoNivel = 0)
	BEGIN
		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
					set @xvalor = (@xvalor *-1)
					--set @xvalor = '123465798'
	END

END


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnPPTOCIS]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnPPTOCIS](@ano varchar(20),@IDPresupuesto varchar(50),@CCosto varchar(20), @nivelCuenta varchar(20),@bd varchar(30),@mes varchar(6),@condicion int) 
returns float(50)
as
BEGIN
declare @xvalor float(50)
declare @xvalorDist float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float(50)
declare @obtengoNivel int
declare @existeSuma int
Declare @tipocuenta varchar(50)

set @obtengoNivel = (select idNivel from dscis.dbo.DS_nivelesEERR where idcuenta = @nivelCuenta AND bdsession = @bd)

--select * from dscis.dbo.DS_AgrupacionCuentas where idNivel = '5'
--select * from dscis.dbo.DS_nivelesEERR where idcuenta = '5'

IF(@condicion = 1)
BEGIN
set @existeDist = 
(
	--select * from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '13-001' AND idCuenta =  '5' AND valor <> '100' AND valor <> '0'
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta =  @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano
)
	BEGIN
--INICIO BLOQUE POR NIVEL
		IF(@obtengoNivel = 0)
			BEGIN
						set @existeDist = (select count(*) as existeDist 
											from [DSCIS].[dbo].[DS_DistribucionCC] 
											 where CodiCC = @CCosto and idCuenta = @nivelCuenta 
											 AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
						set @existeSuma = (select Suma 
											from [DSCIS].[dbo].[DS_DistribucionCC]
											where CodiCC = @CCosto and idCuenta = @nivelCuenta
											 AND bdsession = @bd and ano = @ano)
			IF(@existeDist = 1)
				BEGIN
								set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  
				where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				
				set @xvalor = (SELECT isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma FROM  CIS.softland.cwpreop 
					WHERE PreopAno = @ano AND Preop_id = @IDPresupuesto AND PreopCC = @CCosto AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					) AND PreopMes = @mes)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
							IF(@existeSuma > 0)
								BEGIN
									set @xvalorSuma = (SELECT isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano AND Preop_id = @IDPresupuesto AND PreopCC = @CCosto 
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN (select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] 
																			WHERE idNivel =  @nivelCuenta AND BDSession = @bd)
							AND PreopMes = @mes)
						
						set @xvalor = (@xvalor + @xvalorSuma)

									end

			end
	end

IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		set @porcentaje =(select valor as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
								
		IF(@existeDist = 1)
		begin 
		set @porcentaje =(select valor as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
			   if(@nivelcuenta=1)
						begin 
						set @xvalor = 
						(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
						WHERE PreopCta IN ('4-1-05-042') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
						AND preopano='2019' AND PreopCC  like '12-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
					end
					if(@nivelcuenta=2)
			 begin 
						set @xvalor = 
						(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
						WHERE PreopCta IN ('4-1-01-003','4-1-01-005') AND preopmes BETWEEN  00 and CONVERT(INT, @mes)
						AND preopano='2019' AND preopcc  like '12-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
				end
					if(@nivelcuenta=3)
					begin 
						set @xvalor =
							(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-042') AND preopmes between 00 and  CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC like '12-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
			       end


					if(@nivelcuenta=4)
					begin 
							set @xvalor =(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND preopcc  like '12-%' AND Preop_id='CIS 2019' )
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end


					if(@nivelCuenta=5)
					begin 
							set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN ('4-1-05-007','4-1-05-009',
							'4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019','4-1-05-021','4-1-05-023',
							'4-1-05-025','4-1-05-031','4-1-05-033','4-1-05-035','4-1-05-037','4-1-05-041',
							'4-1-05-043','4-1-05-046','4-1-05-047',
							'4-1-05-055','4-1-05-099'
								)   and preopano='2019' AND preopmes BETWEEN 00 and CONVERT(INT, @mes))
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end

				if(@nivelcuenta=6)
				begin 
							set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN('4-1-05-001','4-1-05-002') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano=@ano AND preopcc like '12-%'  AND Preop_id='CIS 2019')
						set @xvalor = ((@xvalor*@porcentaje)/100)
				end


				if(@nivelcuenta=7)
					begin 
						set @xvalor = (
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN (
						'4-1-05-007','4-1-05-009','4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019',
						'4-1-05-021','4-1-05-023','4-1-05-025','4-1-05-031','4-1-05-033','4-1-05-035',
						'4-1-05-037','4-1-05-041','4-1-05-043','4-1-05-046','4-1-05-047','4-1-05-055',
						'4-1-05-099'
						)   and preopano=@ano AND preopmes BETWEEN 00 AND 	CONVERT(INT, @mes) AND Preop_id='CIS 2019'	)	
						set @xvalor = ((@xvalor*@porcentaje)/100 )
			end
		
		if(@nivelcuenta=8)
    	begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-099') and preopmes between  00 AND
										CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc like '12-%' AND Preop_id='CIS 2019')
						set @xvalor = ((@xvalor*@porcentaje)/100)
			end

			if(@nivelcuenta=9)
				begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-010') and preopmes BETWEEN 00
										 AND CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc  like '12-%' AND Preop_id='CIS 2019' )
						set @xvalor = ((@xvalor*@porcentaje)/100)
		     	end
				end
      else if(@existeDist=0)
				begin
				  if(@nivelcuenta=1)
				begin 
							set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
											WHERE PreopCta IN ('4-1-05-042') AND preopmes BETWEEN 00
											AND CONVERT(INT, @mes) AND PreopCC  like @CCosto+'%'
											AND preopano='2019'  AND Preop_id='CIS 2019' )
								if(@xvalor=null)
									begin
											return 0;
									end
		end				
		if(@nivelcuenta=2)
				begin 
					set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
      								WHERE PreopCta IN ('4-1-01-003','4-1-01-005') AND preopmes BETWEEN  00 AND CONVERT(INT, @mes) 
									AND preopano='2019' AND PreopCC  like @CCosto+'%'AND Preop_id='CIS 2019' )
									if(@xvalor=null)
									begin
										return 0;
									end
									end
	  	if(@nivelcuenta=3)
				begin 
				set @xvalor =(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
			  				WHERE PreopCta IN ('4-1-05-042') AND preopmes BETWEEN  00
							AND CONVERT(INT, @mes) 
							AND preopano='2019' AND PreopCC  like @CCosto+'%'    AND Preop_id='CIS 2019' )
						if(@xvalor=null)
							begin
								return 0;
							end
			     end
    	if(@nivelcuenta=4)
					begin 
							set @xvalor =(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND preopmes BETWEEN 00 AND
							CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like @CCosto+'-%'   AND Preop_id='CIS 2019' )
							if(@xvalor=null)
							begin
								return 0;
							end
							end
							
		if(@nivelcuenta=5)
					begin 
				set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN ('4-1-05-007',
						'4-1-05-009','4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019',
						'4-1-05-021','4-1-05-023','4-1-05-025','4-1-05-031','4-1-05-033',
	                    '4-1-05-035','4-1-05-037','4-1-05-041','4-1-05-043','4-1-05-046',
						'4-1-05-047','4-1-05-055','4-1-05-099')   and preopano='2019' AND   preopmes  BETWEEN 00 and CONVERT(INT, @mes)   
						AND Preop_id='CIS 2019' and  preopcc like @CCosto+'%')
						if(@xvalor=null)
							begin
							return 0;
							end
						
				end
    	if(@nivelcuenta=6)
    		    begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
						WHERE PreopCta IN('4-1-05-001','4-1-05-002') AND preopmes between 00 and CONVERT(INT, @mes)
						AND preopano=@ano AND preopcc like @CCosto+'%'  AND Preop_id='CIS 2019' )
						if(@xvalor=null)
							begin
							return 0;
							end		
				end
		if(@nivelcuenta=7)
				begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN (
						'4-1-05-007','4-1-05-009','4-1-05-011','4-1-05-015','4-1-05-017',
						'4-1-05-019','4-1-05-021','4-1-05-023','4-1-05-025','4-1-05-031',
						'4-1-05-033','4-1-05-035','4-1-05-037','4-1-05-041','4-1-05-043',
						'4-1-05-046','4-1-05-047','4-1-05-055',
						'4-1-05-099') and preopano=@ano AND preopmes BETWEEN 00 and CONVERT(INT, @mes) and preopcc  like @CCosto+'%' and Preop_id='CIS 2019')
						if(@xvalor=null)
							begin
							return 0;
							end
						
	 			end


					if(@nivelcuenta=8)
					begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-099') and preopmes BETWEEN 00 and CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc  like @CCosto+'%' AND preop_id='CIS 2019')
						if(@xvalor=null)
							begin
								return 0;
							end

						end

						if(@nivelcuenta=9)
						begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-010') and preopmes BETWEEN 00 and CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc  like @CCosto+'%' AND Preop_id='CIS 2019')
										if(@xvalor=null)
							begin
								return 0;
							end

				end
								end
				


END

IF(@obtengoNivel = 2)
	BEGIN
			 set @existeDist = (select count(*) as existeDist 
								 from [DSCIS].[dbo].[DS_DistribucionCC]
								where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta 
								AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma 
							    	from [DSCIS].[dbo].[DS_DistribucionCC] 
							     	where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  
							    	AND bdsession = @bd  and ano = @ano)
				set @porcentaje=(select valor as existeDist
						    	 from [DSCIS].[dbo].[DS_DistribucionCC]
							    where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta 
							   AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
			
if(@existeSuma>0)
begin
				if(@nivelcuenta=10)
					begin 
							set @xvalor = 
							(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like '11-001' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
							set @xvalor=((@xvalor*@porcentaje)/100)

							   SET @xvalorsuma=(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like '11-001' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
								
								set @xvalor=((@xvalor*@porcentaje)/100)
								set @xvalor=@xvalor+@xvalorSuma;
					end
					
				if(@nivelcuenta=11)	 
					begin 
						set @xvalor =(SELECT sum(preopdebe-preophaber)
										 FROM CIS.softland.cwpreop
									WHERE PreopCta IN ('4-1-05-051') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
									AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
						
							set @xvalor=((@xvalor*@porcentaje)/100)

                SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
								 FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-051') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
								AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
								set @xvalor=((@xvalor*@porcentaje)/100)
								set @xvalor=@xvalor+@xvalorSuma;
					end
				 
			
				if(@nivelcuenta=12)	 
				begin 
						set @xvalor = 
							(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
							WHERE PreopCta IN ('4-1-05-005') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

					    SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
								 FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-005') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
								AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
								set @xvalor=((@xvalor*@porcentaje)/100)
								set @xvalor=@xvalor+@xvalorSuma;
				end
	
	
			if(@nivelcuenta=13)	 
				begin 
					set @xvalor = 
						(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
						WHERE PreopCta IN ('4-1-01-009') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
						AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

	                SET @xvalorsuma=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
						WHERE PreopCta IN ('4-1-01-009') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
						AND preopano='2019' AND PreopCC  like '11-%' AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
				end


			if(@nivelcuenta=14)	 
				begin 
					set @xvalor = 
							(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
							WHERE PreopCta IN ('4-1-05-006'
							,'4-1-05-007','4-1-05-009','4-1-05-011','4-1-05-015'
							,'4-1-05-017','4-1-05-019','4-1-05-025','4-1-05-027'
							,'4-1-05-033','4-1-05-034','4-1-05-037','4-1-05-041'
							,'4-1-05-051','4-1-05-055','4-1-05-099')
							 AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

				     SET @xvalorsuma=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-006','4-1-05-007','4-1-05-009'
								,'4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019'
								,'4-1-05-025','4-1-05-027','4-1-05-033','4-1-05-034'
								,'4-1-05-037','4-1-05-041','4-1-05-051','4-1-05-055'
								,'4-1-05-099') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
	     		end

				if(@nivelcuenta=15)	 
					begin 
									set @xvalor =(SELECT sum(preopdebe-preophaber) 
										FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-028','4-1-05-029',
										'4-1-05-030','4-1-05-032')
									    AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
										AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

							SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
										 FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-028','4-1-05-029','4-1-05-030','4-1-05-032')
										AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
										AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
										set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
					end
					
				
			 if(@nivelcuenta=16)	 
				begin 
					set @xvalor = 
									(SELECT sum(preopdebe-preophaber)
										 FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-028','4-1-05-029','4-1-05-030'
									 ,'4-1-05-032') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
									AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
				
								set @xvalor=((@xvalor*@porcentaje)/100)
				
							 SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
											 FROM CIS.softland.cwpreop
											WHERE PreopCta IN ('4-1-05-028','4-1-05-029',
											'4-1-05-030','4-1-05-032')
											 AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
											AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
			  end	
end				
			
			

			
	IF(@existeDist = 1)
		BEGIN 
			
			 if(@nivelcuenta=10)
				begin
						set @xvalor=
								(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like '11-001' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
						set @xvalor = ((@xvalor*@porcentaje)/100)							
				end
			
			
			if(@nivelcuenta=11)
					begin 
							set @xvalor=(SELECT sum(preopdebe-preophaber) 
										 FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-051')   and PreopCC=@CCosto+'-%'
										AND Preopmes BETWEEN 00 and CONVERT(INT, @mes) and PreopCC like '11-%' )
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end

		    if(@nivelcuenta=12)
			begin
							set @xvalor=(SELECT sum(preopdebe-preophaber)
										FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-005')
										and PreopCC like '11-%'AND Preopmes BETWEEN 00 and CONVERT(INT, @mes))
							set @xvalor = ((@xvalor*@porcentaje)/100)
			end

		   
		    if(@nivelcuenta=13)
			begin
							set @xvalor=(SELECT sum(preopdebe-preophaber) 
										FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-01-009')AND Preopmes
										BETWEEN 00 and CONVERT(INT, @mes) and preopcc like '11-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)
			end
	           
		   
		   if(@nivelcuenta=14)
		   	begin
			set @xvalor=(SELECT sum(preopdebe-preophaber) 
						FROM CIS.softland.cwpreop
						 WHERE PreopCta IN ('4-1-05-006','4-1-05-007','4-1-05-009',
									'4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019','4-1-05-025','4-1-05-027',
									'4-1-05-033','4-1-05-034','4-1-05-037','4-1-05-041','4-1-05-051','4-1-05-055'
									,'4-1-05-099')
						AND Preopmes BETWEEN 00 and CONVERT(INT, @mes) AND 
						preopano=@ano AND preopcc like '11-%')
						set @xvalor = ((@xvalor*@porcentaje)/100)
			end
			
							
			   if(@nivelcuenta=15)
		   	begin
					set @xvalor=(SELECT sum(preopdebe-preophaber) 
								FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-028','4-1-05-029','4-1-05-030','4-1-05-032')
								AND Preopmes BETWEEN 00 AND CONVERT(INT, @mes) AND preopano=@ano AND preopcc like '11-%' AND 
								Preopmes BETWEEN 00 and 03 and	
								preopano='2019' AND preopcc like '11-%')
					set @xvalor = ((@xvalor*@porcentaje)/100)
			end	
			
	         if(@nivelcuenta=16)
			begin
						set @xvalor=(SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop
						  WHERE PreopCta IN ('4-1-05-028'
						,'4-1-05-029','4-1-05-030','4-1-05-032')AND Preopmes BETWEEN 00 and CONVERT(INT, @mes) 
						and preopano='2019' AND preopcc like '11-%')
					set @xvalor = ((@xvalor*@porcentaje)/100)
			end
			
		
		end
else
		BEGIN 						
				if(@nivelcuenta=10)
					begin
							set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like @CCosto+'%' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
									
								if(@xvalor=0)
									begin 
										set @xvalor=0;
									return @xvalor
								end
					END
		    	
				
				if(@nivelcuenta=11)
					begin 	
					set @xvalor=(SELECT sum(preopdebe-preophaber) 
								FROM CIS.softland.cwpreop 
								WHERE PreopCta IN ('4-1-05-051') AND Preopmes 
								 BETWEEN 00 AND CONVERT(INT, @mes))
			       
						    if(@xvalor=0)
								begin 
								set @xvalor=0;
								return @xvalor;
							end
				end
			
				if(@nivelcuenta=12)
				begin
					set @xvalor=(SELECT sum(preopdebe-preophaber)
							FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-005') 
							AND Preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano=@ano AND preopcc like @CCosto+'%' )
				
						if(@xvalor=0)
						begin 
							set @xvalor=0;
						return @xvalor
						end
				end
			  
			    if(@nivelcuenta=13)
				begin
				set @xvalor=
							(SELECT sum(preopdebe-preophaber)
							FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-01-009')AND Preopmes 
							BETWEEN 00 and CONVERT(INT, @mes) and preopcc like @CCosto+'%' )
				
						if(@xvalor=0)
						begin 
							set @xvalor=0;
							return @xvalor
						end
				end
		
			 if(@nivelcuenta=14)
				begin
					set @xvalor=(SELECT sum(preopdebe-preophaber) 
								FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-006'
								,'4-1-05-007','4-1-05-009','4-1-05-011'
								,'4-1-05-015','4-1-05-017','4-1-05-019'
								,'4-1-05-025','4-1-05-027','4-1-05-033'
								,'4-1-05-034','4-1-05-037','4-1-05-041'
								,'4-1-05-051','4-1-05-055','4-1-05-099')
								AND Preopmes BETWEEN 00 AND CONVERT(INT, @mes)
								AND preopano=@ano AND preopcc like  @CCosto+'-%' and preopcc like @CCosto+'%' )
						if(@xvalor=0)
						begin 
								set @xvalor=0;
								return @xvalor
							end
				end


			if(@nivelcuenta=15)
				begin
					set @xvalor=(SELECT sum(preopdebe-preophaber)
								FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-028'
										,'4-1-05-029','4-1-05-030','4-1-05-032')
										AND Preopmes BETWEEN 00 AND CONVERT(INT, @mes)
										 AND preopano=@ano AND preopcc like @CCosto+'-%'
									 AND preopano='2019' AND preopcc like  @CCosto+'-%' )
								if(@xvalor=0)
								begin 
										set @xvalor=0
										return @xvalor
								end
					end
	     
		 
					 if(@nivelcuenta=16)
						begin	
							set @xvalor=(SELECT sum(preopdebe-preophaber)
								FROM CIS.softland.cwpreop 
								 WHERE PreopCta IN ('4-1-05-028','4-1-05-029'
								,'4-1-05-030','4-1-05-032')
								AND Preopmes between  00 and CONVERT(INT, @mes) 
								AND preopano=@ano AND preopcc like  @CCosto+'-%')
								if(@xvalor=0)
								begin 
									set @xvalor=0;
									return @xvalor
								end
					end
						
						
		end
	end	
	
end		

end		
return @xvalor;
end	
					
	/*			if @xvalor = NULL
set @xvalor = 0
return @xvalor

				END


				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '11-001'
					AND PreopCC = '11-%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN 00 AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
			END	
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN 00 AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '00' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				END
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '00' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
END



end	
if @xvalor = NULL
set @xvalor = 0
return @xvalor
END

					
		--	BEGIN
		--		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
		--		set @xvalor =
		--		(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = '11-001'
		--			AND PreopCC like '12-001%'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--		end
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '00' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END


			
		--ELSE
		--	BEGIN
		--		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
		--		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		--		set @xvalor = 
		--		(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = @CCosto
		--			AND PreopCC like @CCosto+'%'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--		end
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '01' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END
			

		--END

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		 set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]
									where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta 
									AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
			set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] 
								where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  
								AND bdsession = @bd  and ano = @ano)
			IF(@existeDist = 1)
			BEGIN 
			   if(@nivelcuenta=10)
								begin
									set @xvalor=
										(SELECT sum(preopdebe-preophaber) 
											FROM CIS.softland.cwpreop 
											WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND Preopmes 
											BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%' )
											set @xvalor = ((@xvalor*@porcentaje)/100)
								end
								if(@nivelcuenta=11)
									begin 
				
				 set @xvalor=(SELECT sum(preopdebe-preophaber) 
				 FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-051') AND Preopmes 
				 BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%')
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end

				if(@nivelcuenta=12)
				begin
				set @xvalor=(
				SELECT sum(preopdebe-preophaber) 
				FROM CIS.softland.cwpreop 
				WHERE PreopCta IN ('4-1-05-005') AND Preopmes 
				BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%' )
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end

			    if(@nivelcuenta=13)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-01-009')AND Preopmes
				 BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%')
			    set @xvalor = ((@xvalor*@porcentaje)/100)
				end
	           
			   if(@nivelcuenta=14)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-006'
						,'4-1-05-007'
						,'4-1-05-009'
						,'4-1-05-011'
						,'4-1-05-015'
						,'4-1-05-017'
						,'4-1-05-019'
						,'4-1-05-025'
						,'4-1-05-027'
						,'4-1-05-033'
						,'4-1-05-034'
						,'4-1-05-037'
						,'4-1-05-041'
						,'4-1-05-051'
						,'4-1-05-055'
						,'4-1-05-099'
						)AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND 
						preopano=@ano AND preopcc like '11-%')
										set @xvalor = ((@xvalor*@porcentaje)/100)
							end
							
			   if(@nivelcuenta=15)
					begin
					set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND @mes AND preopano=@ano AND preopcc like '11-%' AND 
						Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND 
						preopano='2019' AND preopcc like '11-%')
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end
				   if(@nivelcuenta=16)
						begin
						set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND
						 preopano=@ano AND preopcc like '11-%')
						set @xvalor = ((@xvalor*@porcentaje)/100)
				end
	END

	else
	BEGIN 						
				if(@nivelcuenta=10)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) 
				FROM CIS.softland.cwpreop 
				WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND 
				Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2) 
				AND preopano=@ano AND preopcc like @CCosto+'%' )
				end
		    	if(@nivelcuenta=11)
				begin 	
				 set @xvalor=(SELECT sum(preopdebe-preophaber) 
				 FROM CIS.softland.cwpreop 
				 WHERE PreopCta IN ('4-1-05-051') AND Preopmes 
				 BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like @CCosto+'%')
				end
				if(@nivelcuenta=12)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber)
				 FROM CIS.softland.cwpreop 
				 WHERE PreopCta IN ('4-1-05-005') 
				 AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2) 
				 AND preopano=@ano AND preopcc like @CCosto+'%' )
				
				end

			    if(@nivelcuenta=13)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-01-009')AND Preopmes 
				BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '@CCosto')
		end
	    if(@nivelcuenta=14)
     	begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-006'
						,'4-1-05-007'
						,'4-1-05-009'
						,'4-1-05-011'
						,'4-1-05-015'
						,'4-1-05-017'
						,'4-1-05-019'
						,'4-1-05-025'
						,'4-1-05-027'
						,'4-1-05-033'
						,'4-1-05-034'
						,'4-1-05-037'
						,'4-1-05-041'
						,'4-1-05-051'
						,'4-1-05-055'
						,'4-1-05-099'
						)AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2) 
						AND preopano=@ano AND preopcc like '@CCosto')
				end
			   if(@nivelcuenta=15)
				begin
				set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND @mes AND preopano=@ano AND preopcc like '@CCosto'
						 AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)
						 AND preopano='2019' AND preopcc like '@CCosto')
				end
	  		   if(@nivelcuenta=16)
			begin	
				set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)
						AND preopano=@ano AND preopcc like '@CCosto')
			    
				end
end
end

	
				--set @xvalor =
				--(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = '11-001'
		--			AND PreopCC = '11-001'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--	END	
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '01' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END


		--	END
		--ELSE
		--	BEGIN
		--		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
		--		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		--		set @xvalor = 
		--		(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = @CCosto
		--			AND PreopCC like @CCosto+'%'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--		END
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '00' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END
--END

	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				end
				--set @xvalor = '3'
				if(@nivelcuenta=17)
					begin
					set @xvalor = 
						(SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-001','4-1-05-002') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND PreopCC like '01-%' )						
				set @xvalor = ((@xvalor*@porcentaje)/100)
					end
				if(@nivelcuenta=18)
				begin
				set @xvalor = 
						(SELECT sum(preopdebe-preophaber) 
						FROM CIS.softland.cwpreop 
						WHERE preopcta IN
						 ('4-1-05-007',
						 '4-1-05-009',
						 '4-1-05-011',
						 '4-1-05-013',
						 '4-1-05-015',
						 '4-1-05-017',
						 '4-1-05-019',
						 '4-1-05-021',
						 '4-1-05-025',
						 '4-1-05-027',
						 '4-1-05-033',
						 '4-1-05-035',
						 '4-1-05-037',
						 '4-1-05-041',
						 '4-1-05-043',
						 '4-1-05-046',
						 '4-1-05-047',
						 '4-1-05-051',
						 '4-1-05-053',
						 '4-1-05-055',
						 '4-1-05-099',
						 '5-1-01-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103) 
						   AND preopano=@ano AND preopcc like '01-%' )
						   end
	if(@nivelcuenta=26)
				begin
				set @xvalor = 
					   (SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND preopcc like '01-%' )
				set @xvalor = ((@xvalor*@porcentaje)/100)
			end
	else
			if(@nivelcuenta=17)
					begin
					set @xvalor = 
						(SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-001','4-1-05-002') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND PreopCC like @CCosto )
		 		set @xvalor = ((@xvalor*@porcentaje)/100)
				end
				if(@nivelcuenta=18)
				begin
				set @xvalor = 
						(SELECT sum(preopdebe-preophaber) 
						FROM CIS.softland.cwpreop 
						WHERE preopcta IN
						 ('4-1-05-007',
						 '4-1-05-009',
						 '4-1-05-011',
						 '4-1-05-013',
						 '4-1-05-015',
						 '4-1-05-017',
						 '4-1-05-019',
						 '4-1-05-021',
						 '4-1-05-025',
						 '4-1-05-027',
						 '4-1-05-033',
						 '4-1-05-035',
						 '4-1-05-037',
						 '4-1-05-041',
						 '4-1-05-043',
						 '4-1-05-046',
						 '4-1-05-047',
						 '4-1-05-051',
						 '4-1-05-053',
						 '4-1-05-055',
						 '4-1-05-099',
						 '5-1-01-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103) 
						   AND preopano=@ano AND preopcc like @CCosto+'%' )
						   end
				if(@nivelcuenta=26)
					begin
					set @xvalor = 
					   (SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND preopcc like @CCosto+'%' )
					set @xvalor = ((@xvalor*@porcentaje)/100)
	end
end

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @tipocuenta = (select b.PCTIPO from CIS.softland.cwpreop a inner join cis.softland.cwpctas b on a.preopcta = pccodi 
		where a.preop_id =@IDPresupuesto and a.preopAno = @ano and a.preopcc like @CCosto +'%' and a.preopMes = @mes AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd))


		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	IF(@obtengoNivel = 0)
	BEGIN
		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
					set @xvalor = (@xvalor *-1)
					--set @xvalor = '123465798'
	END

END


END  

*/
GO
/****** Object:  UserDefinedFunction [dbo].[returnPPTOCIS2]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnPPTOCIS2](@ano varchar(20),@IDPresupuesto varchar(50),@CCosto varchar(20), @nivelCuenta varchar(20),@bd varchar(30),@mes varchar(6),@condicion int) 
returns float(50)
as
BEGIN
declare @xvalor float(50)
declare @xvalorDist float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float(50)
declare @obtengoNivel int
declare @existeSuma int
Declare @tipocuenta varchar(50)
declare @centrocosto varchar(50)

set @obtengoNivel = (select idNivel from dscis.dbo.DS_nivelesEERR where idcuenta = @nivelCuenta AND bdsession = @bd)

IF(@condicion = 0)
BEGIN
set @existeDist = (select valor as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] 
where codiCC = @CCosto AND idCuenta =  @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)

BEGIN
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 0)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  
		where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)

		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  
		where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  
				where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				
				set @xvalor = (SELECT isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma FROM  CIS.softland.cwpreop 
					WHERE PreopAno = @ano AND Preop_id = @IDPresupuesto AND PreopCC = @CCosto AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					) AND PreopMes = @mes)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = (SELECT isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano AND Preop_id = @IDPresupuesto AND PreopCC = @CCosto 
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN (select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] 
																			WHERE idNivel =  @nivelCuenta AND BDSession = @bd)
							AND PreopMes = @mes)
						
						set @xvalor = (@xvalor + @xvalorSuma)
					END
			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  
				where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  
				where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				
				set @xvalor = (SELECT isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano AND Preop_id = @IDPresupuesto AND PreopCC = @CCosto 
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN (select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] 
																	WHERE idNivel =  @nivelCuenta AND BDSession = @bd)
					AND PreopMes = @mes)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = (SELECT isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano AND Preop_id = @IDPresupuesto AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN (select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] 
																			WHERE idNivel =  @nivelCuenta AND BDSession = @bd)
							AND PreopMes = @mes)
						
						set @xvalor = (@xvalor + @xvalorSuma)
					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '12-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '11-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
--@nivelCuenta

				IF(@nivelCuenta = 21 OR @nivelCuenta = 22 OR @nivelCuenta = 25)
				BEGIN
					set @xvalor = (@xvalor *-1)
				END
				

				IF(@nivelCuenta = 20)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

				IF(@nivelCuenta = 24)
				BEGIN
					IF(@xvalor >0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano )
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		
		set @tipocuenta = (select b.PCTIPO from CIS.softland.cwpreop a inner join cis.softland.cwpctas b on a.preopcta = pccodi 
		where a.preop_id =@IDPresupuesto and a.preopAno = @ano and a.preopcc like @CCosto+'%' and a.preopMes = @mes AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd))

		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = (@xvalor * @xvalorDist)				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	


	END

END
ELSE
BEGIN
/*
set @xvalor = 
(
	SELECT 
	isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
	FROM  CIS.softland.cwpreop
	WHERE PreopAno = @ano
	AND Preop_id = @IDPresupuesto
	AND PreopCC = @CCosto
	AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
	)
	AND PreopMes BETWEEN '01' AND @mes
)

set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto and idCuenta = @nivelCuenta)

set @xvalor = ((@xvalor * @porcentaje)/100)
*/

IF(@obtengoNivel = 1)
	BEGIN
		
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =(SELECT  isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND SUBSTRING(CodiCC,1,2) collate Modern_Spanish_CI_AS in (select SUBSTRING(codicc,1,2) from DSCIS.DBO.ccdistribuible where idnivel=@obtengoNivel )

					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel  AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			--set @xvalor = '123465798'

			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				--set @centrocosto =(select codicc from dscis.dbo.ccdistribuible where idnivel=@nivelcuenta)
		
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '11-001'
					AND PreopCC like '11%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT  isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND SUBSTRING(CodiCC,1,2) collate Modern_Spanish_CI_AS in (select SUBSTRING(codicc,1,2) from DSCIS.DBO.ccdistribuible where idnivel=@obtengoNivel )

					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel  AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		--set @centrocosto =(select codicc from dscis.dbo.ccdistribuible where idnivel=@nivelcuenta)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT  isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND SUBSTRING(CodiCC,1,2) collate Modern_Spanish_CI_AS in (select SUBSTRING(codicc,1,2) from DSCIS.DBO.ccdistribuible where idnivel=@obtengoNivel )

					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel  AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =(SELECT  isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel  AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =(SELECT  isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel  AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				IF (@xvalor < 0)
				BEGIN
					set @xvalor = @xvalor *-1
				END
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	IF(@obtengoNivel = 0)
	BEGIN
		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC =  @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
					set @xvalor = (@xvalor *-1)
					--set @xvalor = '123465798'
	END

END


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnpptocis2_R]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[returnpptocis2_R] ( @preopano as varchar(10),@preopid  varchar(50), @pCCosto as varchar(10), @pnivel as int ,@pbd as varchar(50),@mes as int ,@condicion int )
returns int
as
begin 
declare @wxvalor as int
declare @wexisteDist as int
declare @wexistesuma as int 
declare @wporcentaje as float
declare @wxvalor2 as int
declare @wxvalorporcentaje as int 
set @wexisteSuma = (select Suma from [RSPHOLA].[dbo].[DS_DistribucionCC] where codiCC = @pCCosto+'-000' AND idCuenta = @pnivel AND BDSession = @pbd  and ano =@preopano)
set @wporcentaje = (select valor from [RSPHOLA].[dbo].[DS_DistribucionCC] where codiCC = @pCCosto+'-000' AND idCuenta = @pnivel AND BDSession = @pbd and ano = @preopano)


set @wexisteDist = 
(
	--select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @pCCosto AND idCuenta = @pnivel
	select count(valor) as existeDist from [RSPHOLA].[dbo].[DS_DistribucionCC] where codiCC =@pCCosto+'-000' AND idCuenta =  @pnivel AND valor <> '100' AND BDSession = @pbd and ano = @preopano
)


		

	

				if(@wexisteDist=0)
				begin
					set @wxvalor=(
					select sum(preopdebe-preophaber) 
					from cis.softland.cwpreop 
					where   preopcc LIKE  @pCCosto+'-%'
					and preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    (
					SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))
						
									set @wxvalor=@wxvalor*-1
				end

					
						if(@pnivel>=6 and @pnivel<=7)
				BEGIN
					set @wxvalor=(
					select sum(preophaber-preopdebe) 
					from cis.softland.cwpreop 
					where   preopcc LIKE @pCCosto+'-%'
					and preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND  @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    (
					SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))
				end	
		if(@wexisteDist>0)
		begin
		
				if(@pnivel>=1 and @pnivel<=3)
				BEGIN
					set @wxvalor=(
					select sum(preophaber-preopdebe) 
					from cis.softland.cwpreop 
					where   preopcc LIKE  @pCCosto+'-%'
					and preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND  @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    (
					SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))
						set @wxvalor=(@wxvalor* @wporcentaje)/100;
				end
	
				if(@pnivel>=4 and @pnivel<=5 )
				BEGIN
				set @wxvalor=(
					select sum(preopdebe-preophaber) 
					from cis.softland.cwpreop 
					where   preopcc LIKE '12-%'
					and preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND   @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    (
					SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))
			set @wxvalor=(@wxvalor*@wporcentaje)/100;
			end

				if(@pnivel>=10 and @pnivel<=16)
				begin
					set @wxvalor=(
					select sum(preopdebe-preophaber) 
					from cis.softland.cwpreop 
					where   preopcc LIKE '11-%'
					and preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND  @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    (
					SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))
				set @wxvalor=(@wxvalor*@wporcentaje)/100;
				end

					if(@pnivel>=17 and @pnivel<=18)
				begin
					set @wxvalor=(
					select sum(preopdebe-preophaber) 
					from cis.softland.cwpreop 
					where   preopcc LIKE '01-%'
					and preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND  @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    (
					SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))
				set @wxvalor=(@wxvalor*@wporcentaje)/100;
				end
				if(@pnivel=19 )
			begin
				set @wxvalor=(
					select sum(preopdebe-preophaber) 
					from cis.softland.cwpreop 
					where  
					 preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    (
					SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))
					set @wxvalor=(@wxvalor*@wporcentaje)/100;
			end
			end
	
	if( @wexisteSuma>0)
	begin
				if(@pnivel>=1 and @pnivel <= 9 )
				begin
					set @wxvalor=(
					select sum(preopdebe-preophaber) 
					from cis.softland.cwpreop 
					where   preopcc LIKE @pCCosto+'-%'
					and preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND  @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    (
					SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))
					set @wxvalor2=(
					select sum(preopdebe-preophaber) 
					from cis.softland.cwpreop 
					where   preopcc LIKE '12-%'	
					and preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND  @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    (
					SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))
				set @wxvalor=@wxvalor+@wxvalor2;
				end

				if(@pnivel>=10 and @pnivel <= 16 )
				begin
				set @wxvalor=(
					select sum(preopdebe-preophaber) 
					from cis.softland.cwpreop 
					where   preopcc LIKE @pCCosto+'-%'
					and preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND  @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    (
					SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))
					
					set @wxvalor2=(
					select sum(preopdebe-preophaber) 
					from cis.softland.cwpreop 
					where   preopcc LIKE '11-%'	
					and preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND  @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    (
					SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))
			set @wxvalor=@wxvalor+@wxvalor2;
			end
			
			if(@pnivel>=17 and @pnivel<=18)
			begin
				set @wxvalor=(
					select sum(preopdebe-preophaber) 
					from cis.softland.cwpreop 
					where   preopcc LIKE @pCCosto+'-%'
					and preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    
					(SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))
					
				set @wxvalor2=(
					select sum(preopdebe-preophaber) 
					from cis.softland.cwpreop 
					where   preopcc LIKE '01-%'
					and preopano=@preopano
					and Preop_id=@preopid
					AND PREOPMES BETWEEN 00 AND @mes
					AND PreopCta collate Modern_Spanish_CI_AS IN    
					(SELECT PCCODI FROM ESTADORESULTADO.DBO.DS_AgrupacionCuentas WHERE idNivel=@pnivel))

				set @wxvalor=@wxvalor+@wxvalor2;
		end
		
		end
		
			return @wxvalor
		end
	
	
		
GO
/****** Object:  UserDefinedFunction [dbo].[returnPPTOCIS2_respaldo]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[returnPPTOCIS2_respaldo](@ano varchar(20),@IDPresupuesto varchar(50),@CCosto varchar(20), @nivelCuenta varchar(20),@bd varchar(30),@mes varchar(6),@condicion int) 
returns float(50)
as
BEGIN
declare @xvalor float(50)
declare @xvalorDist float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float(50)
declare @obtengoNivel int
declare @existeSuma int
Declare @tipocuenta varchar(50)

set @obtengoNivel = (select idNivel from dscis.dbo.DS_nivelesEERR where idcuenta = @nivelCuenta AND bdsession = @bd)

--select * from dscis.dbo.DS_AgrupacionCuentas where idNivel = '5'
--select * from dscis.dbo.DS_nivelesEERR where idcuenta = '5'

IF(@condicion = 1)
BEGIN
set @existeDist = 
(
	--select * from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '13-001' AND idCuenta =  '5' AND valor <> '100' AND valor <> '0'
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta =  @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano
)
	BEGIN
--INICIO BLOQUE POR NIVEL
		IF(@obtengoNivel = 0)
			BEGIN
						set @existeDist = (select count(*) as existeDist 
											from [DSCIS].[dbo].[DS_DistribucionCC] 
											 where CodiCC = @CCosto and idCuenta = @nivelCuenta 
											 AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
						set @existeSuma = (select Suma 
											from [DSCIS].[dbo].[DS_DistribucionCC]
											where CodiCC = @CCosto and idCuenta = @nivelCuenta
											 AND bdsession = @bd and ano = @ano)
			IF(@existeDist = 1)
				BEGIN
								set @xvalorDist = (select valor
								 from [DSCIS].[dbo].[DS_DistribucionCC]
								   where CodiCC = @CCosto and idCuenta = @nivelCuenta
								    AND bdsession = @bd and ano = @ano)
								
								set @xvalor =
											(SELECT isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
											FROM  CIS.softland.cwpreop
											WHERE PreopAno = @ano
											AND Preop_id = @IDPresupuesto
											AND PreopCC = @CCosto
											AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
											(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
											)
											AND PreopMes = @mes
												)

									set @xvalor = ((@xvalor * @xvalorDist)/100)
				
							IF(@existeSuma > 0)
								BEGIN
									set @xvalorSuma = (SELECT isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
													FROM  CIS.softland.cwpreop
													WHERE PreopAno = @ano
													AND Preop_id = @IDPresupuesto
													AND PreopCC = @CCosto
													AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
													(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
													)
													AND PreopMes = @mes
													)
						
											set @xvalor = (@xvalor + @xvalorSuma)

									end

			end
	end

IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		set @porcentaje =(select valor as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
								
		IF(@existeDist = 1)
		begin 
		set @porcentaje =(select valor as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
			   if(@nivelcuenta=1)
						begin 
						set @xvalor = 
						(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
						WHERE PreopCta IN ('4-1-05-042') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
						AND preopano='2019' AND PreopCC  like '12-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
					end
					if(@nivelcuenta=2)
			 begin 
						set @xvalor = 
						(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
						WHERE PreopCta IN ('4-1-01-003','4-1-01-005') AND preopmes BETWEEN  00 and CONVERT(INT, @mes)
						AND preopano='2019' AND preopcc  like '12-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
				end
					if(@nivelcuenta=3)
					begin 
						set @xvalor =
							(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-042') AND preopmes between 00 and  CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC like '12-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
			       end


					if(@nivelcuenta=4)
					begin 
							set @xvalor =(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND preopcc  like '12-%' AND Preop_id='CIS 2019' )
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end


					if(@nivelCuenta=5)
					begin 
							set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN ('4-1-05-007','4-1-05-009',
							'4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019','4-1-05-021','4-1-05-023',
							'4-1-05-025','4-1-05-031','4-1-05-033','4-1-05-035','4-1-05-037','4-1-05-041',
							'4-1-05-043','4-1-05-046','4-1-05-047',
							'4-1-05-055','4-1-05-099'
								)   and preopano='2019' AND preopmes BETWEEN 00 and CONVERT(INT, @mes))
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end

				if(@nivelcuenta=6)
				begin 
							set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN('4-1-05-001','4-1-05-002') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano=@ano AND preopcc like '12-%'  AND Preop_id='CIS 2019')
						set @xvalor = ((@xvalor*@porcentaje)/100)
				end


				if(@nivelcuenta=7)
					begin 
						set @xvalor = (
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN (
						'4-1-05-007','4-1-05-009','4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019',
						'4-1-05-021','4-1-05-023','4-1-05-025','4-1-05-031','4-1-05-033','4-1-05-035',
						'4-1-05-037','4-1-05-041','4-1-05-043','4-1-05-046','4-1-05-047','4-1-05-055',
						'4-1-05-099'
						)   and preopano=@ano AND preopmes BETWEEN 00 AND 	CONVERT(INT, @mes) AND Preop_id='CIS 2019'	)	
						set @xvalor = ((@xvalor*@porcentaje)/100 )
			end
		
		if(@nivelcuenta=8)
    	begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-099') and preopmes between  00 AND
										CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc like '12-%' AND Preop_id='CIS 2019')
						set @xvalor = ((@xvalor*@porcentaje)/100)
			end

			if(@nivelcuenta=9)
				begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-010') and preopmes BETWEEN 00
										 AND CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc  like '12-%' AND Preop_id='CIS 2019' )
						set @xvalor = ((@xvalor*@porcentaje)/100)
		     	end
				end
      else if(@existeDist=0)
				begin
				  if(@nivelcuenta=1)
				begin 
							set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
											WHERE PreopCta IN ('4-1-05-042') AND preopmes BETWEEN 00
											AND CONVERT(INT, @mes) AND PreopCC  like @CCosto+'%'
											AND preopano='2019'  AND Preop_id='CIS 2019' )
								if(@xvalor=null)
									begin
											return 0;
									end
		end				
		if(@nivelcuenta=2)
				begin 
					set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
      								WHERE PreopCta IN ('4-1-01-003','4-1-01-005') AND preopmes BETWEEN  00 AND CONVERT(INT, @mes) 
									AND preopano='2019' AND PreopCC  like @CCosto+'%'AND Preop_id='CIS 2019' )
									if(@xvalor=null)
									begin
										return 0;
									end
									end
	  	if(@nivelcuenta=3)
				begin 
				set @xvalor =(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
			  				WHERE PreopCta IN ('4-1-05-042') AND preopmes BETWEEN  00
							AND CONVERT(INT, @mes) 
							AND preopano='2019' AND PreopCC  like @CCosto+'%'    AND Preop_id='CIS 2019' )
						if(@xvalor=null)
							begin
								return 0;
							end
			     end
    	if(@nivelcuenta=4)
					begin 
							set @xvalor =(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND preopmes BETWEEN 00 AND
							CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like @CCosto+'-%'   AND Preop_id='CIS 2019' )
							if(@xvalor=null)
							begin
								return 0;
							end
							end
							
		if(@nivelcuenta=5)
					begin 
				set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN ('4-1-05-007',
						'4-1-05-009','4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019',
						'4-1-05-021','4-1-05-023','4-1-05-025','4-1-05-031','4-1-05-033',
	                    '4-1-05-035','4-1-05-037','4-1-05-041','4-1-05-043','4-1-05-046',
						'4-1-05-047','4-1-05-055','4-1-05-099')   and preopano='2019' AND   preopmes  BETWEEN 00 and CONVERT(INT, @mes)   
						AND Preop_id='CIS 2019' and  preopcc like @CCosto+'%')
						if(@xvalor=null)
							begin
							return 0;
							end
						
				end
    	if(@nivelcuenta=6)
    		    begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
						WHERE PreopCta IN('4-1-05-001','4-1-05-002') AND preopmes between 00 and CONVERT(INT, @mes)
						AND preopano=@ano AND preopcc like @CCosto+'%'  AND Preop_id='CIS 2019' )
						if(@xvalor=null)
							begin
							return 0;
							end		
				end
		if(@nivelcuenta=7)
				begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN (
						'4-1-05-007','4-1-05-009','4-1-05-011','4-1-05-015','4-1-05-017',
						'4-1-05-019','4-1-05-021','4-1-05-023','4-1-05-025','4-1-05-031',
						'4-1-05-033','4-1-05-035','4-1-05-037','4-1-05-041','4-1-05-043',
						'4-1-05-046','4-1-05-047','4-1-05-055',
						'4-1-05-099') and preopano=@ano AND preopmes BETWEEN 00 and CONVERT(INT, @mes) and preopcc  like @CCosto+'%' and Preop_id='CIS 2019')
						if(@xvalor=null)
							begin
							return 0;
							end
						
	 			end


					if(@nivelcuenta=8)
					begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-099') and preopmes BETWEEN 00 and CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc  like @CCosto+'%' AND preop_id='CIS 2019')
						if(@xvalor=null)
							begin
								return 0;
							end

						end

						if(@nivelcuenta=9)
						begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-010') and preopmes BETWEEN 00 and CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc  like @CCosto+'%' AND Preop_id='CIS 2019')
										if(@xvalor=null)
							begin
								return 0;
							end

				end
								end
				


END

IF(@obtengoNivel = 2)
	BEGIN
			 set @existeDist = (select count(*) as existeDist 
								 from [DSCIS].[dbo].[DS_DistribucionCC]
								where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta 
								AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma 
							    	from [DSCIS].[dbo].[DS_DistribucionCC] 
							     	where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  
							    	AND bdsession = @bd  and ano = @ano)
				set @porcentaje=(select valor as existeDist
						    	 from [DSCIS].[dbo].[DS_DistribucionCC]
							    where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta 
							   AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
			
if(@existeSuma>0)
begin
				if(@nivelcuenta=10)
					begin 
							set @xvalor = 
							(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like '11-001' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
							set @xvalor=((@xvalor*@porcentaje)/100)

							   SET @xvalorsuma=(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like '11-001' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
								
								set @xvalor=((@xvalor*@porcentaje)/100)
								set @xvalor=@xvalor+@xvalorSuma;
					end
					
				if(@nivelcuenta=11)	 
					begin 
						set @xvalor =(SELECT sum(preopdebe-preophaber)
										 FROM CIS.softland.cwpreop
									WHERE PreopCta IN ('4-1-05-051') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
									AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
						
							set @xvalor=((@xvalor*@porcentaje)/100)

                SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
								 FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-051') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
								AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
								set @xvalor=((@xvalor*@porcentaje)/100)
								set @xvalor=@xvalor+@xvalorSuma;
					end
				 
			
				if(@nivelcuenta=12)	 
				begin 
						set @xvalor = 
							(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
							WHERE PreopCta IN ('4-1-05-005') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

					    SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
								 FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-005') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
								AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
								set @xvalor=((@xvalor*@porcentaje)/100)
								set @xvalor=@xvalor+@xvalorSuma;
				end
	
	
			if(@nivelcuenta=13)	 
				begin 
					set @xvalor = 
						(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
						WHERE PreopCta IN ('4-1-01-009') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
						AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

	                SET @xvalorsuma=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
						WHERE PreopCta IN ('4-1-01-009') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
						AND preopano='2019' AND PreopCC  like '11-%' AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
				end


			if(@nivelcuenta=14)	 
				begin 
					set @xvalor = 
							(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
							WHERE PreopCta IN ('4-1-05-006'
							,'4-1-05-007','4-1-05-009','4-1-05-011','4-1-05-015'
							,'4-1-05-017','4-1-05-019','4-1-05-025','4-1-05-027'
							,'4-1-05-033','4-1-05-034','4-1-05-037','4-1-05-041'
							,'4-1-05-051','4-1-05-055','4-1-05-099')
							 AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

				     SET @xvalorsuma=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-006','4-1-05-007','4-1-05-009'
								,'4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019'
								,'4-1-05-025','4-1-05-027','4-1-05-033','4-1-05-034'
								,'4-1-05-037','4-1-05-041','4-1-05-051','4-1-05-055'
								,'4-1-05-099') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
	     		end

				if(@nivelcuenta=15)	 
					begin 
									set @xvalor =(SELECT sum(preopdebe-preophaber) 
										FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-028','4-1-05-029',
										'4-1-05-030','4-1-05-032')
									    AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
										AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

							SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
										 FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-028','4-1-05-029','4-1-05-030','4-1-05-032')
										AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
										AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
										set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
					end
					
				
			 if(@nivelcuenta=16)	 
				begin 
					set @xvalor = 
									(SELECT sum(preopdebe-preophaber)
										 FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-028','4-1-05-029','4-1-05-030'
									 ,'4-1-05-032') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
									AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
				
								set @xvalor=((@xvalor*@porcentaje)/100)
				
							 SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
											 FROM CIS.softland.cwpreop
											WHERE PreopCta IN ('4-1-05-028','4-1-05-029',
											'4-1-05-030','4-1-05-032')
											 AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
											AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
			  end	
end				
			
			

			
	IF(@existeDist = 1)
		BEGIN 
			
			 if(@nivelcuenta=10)
				begin
						set @xvalor=
								(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like '11-001' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
						set @xvalor = ((@xvalor*@porcentaje)/100)							
				end
			
			
			if(@nivelcuenta=11)
					begin 
							set @xvalor=(SELECT sum(preopdebe-preophaber) 
										 FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-051')   and PreopCC=@CCosto+'-%'
										AND Preopmes BETWEEN 00 and CONVERT(INT, @mes) and PreopCC like '11-%' )
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end

		    if(@nivelcuenta=12)
			begin
							set @xvalor=(SELECT sum(preopdebe-preophaber)
										FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-005')
										and PreopCC like '11-%'AND Preopmes BETWEEN 00 and CONVERT(INT, @mes))
							set @xvalor = ((@xvalor*@porcentaje)/100)
			end

		   
		    if(@nivelcuenta=13)
			begin
							set @xvalor=(SELECT sum(preopdebe-preophaber) 
										FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-01-009')AND Preopmes
										BETWEEN 00 and CONVERT(INT, @mes) and preopcc like '11-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)
			end
	           
		   
		   if(@nivelcuenta=14)
		   	begin
			set @xvalor=(SELECT sum(preopdebe-preophaber) 
						FROM CIS.softland.cwpreop
						 WHERE PreopCta IN ('4-1-05-006','4-1-05-007','4-1-05-009',
									'4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019','4-1-05-025','4-1-05-027',
									'4-1-05-033','4-1-05-034','4-1-05-037','4-1-05-041','4-1-05-051','4-1-05-055'
									,'4-1-05-099')
						AND Preopmes BETWEEN 00 and CONVERT(INT, @mes) AND 
						preopano=@ano AND preopcc like '11-%')
						set @xvalor = ((@xvalor*@porcentaje)/100)
			end
			
							
			   if(@nivelcuenta=15)
		   	begin
					set @xvalor=(SELECT sum(preopdebe-preophaber) 
								FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-028','4-1-05-029','4-1-05-030','4-1-05-032')
								AND Preopmes BETWEEN 00 AND CONVERT(INT, @mes) AND preopano=@ano AND preopcc like '11-%' AND 
								Preopmes BETWEEN 00 and 03 and	
								preopano='2019' AND preopcc like '11-%')
					set @xvalor = ((@xvalor*@porcentaje)/100)
			end	
			
	         if(@nivelcuenta=16)
			begin
						set @xvalor=(SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop
						  WHERE PreopCta IN ('4-1-05-028'
						,'4-1-05-029','4-1-05-030','4-1-05-032')AND Preopmes BETWEEN 00 and CONVERT(INT, @mes) 
						and preopano='2019' AND preopcc like '11-%')
					set @xvalor = ((@xvalor*@porcentaje)/100)
			end
			
		
		end
else
		BEGIN 						
				if(@nivelcuenta=10)
					begin
							set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like @CCosto+'%' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
									
								if(@xvalor=0)
									begin 
										set @xvalor=0;
									return @xvalor
								end
					END
		    	
				
				if(@nivelcuenta=11)
					begin 	
					set @xvalor=(SELECT sum(preopdebe-preophaber) 
								FROM CIS.softland.cwpreop 
								WHERE PreopCta IN ('4-1-05-051') AND Preopmes 
								 BETWEEN 00 AND CONVERT(INT, @mes))
			       
						    if(@xvalor=0)
								begin 
								set @xvalor=0;
								return @xvalor;
							end
				end
			
				if(@nivelcuenta=12)
				begin
					set @xvalor=(SELECT sum(preopdebe-preophaber)
							FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-005') 
							AND Preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano=@ano AND preopcc like @CCosto+'%' )
				
						if(@xvalor=0)
						begin 
							set @xvalor=0;
						return @xvalor
						end
				end
			  
			    if(@nivelcuenta=13)
				begin
				set @xvalor=
							(SELECT sum(preopdebe-preophaber)
							FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-01-009')AND Preopmes 
							BETWEEN 00 and CONVERT(INT, @mes) and preopcc like @CCosto+'%' )
				
						if(@xvalor=0)
						begin 
							set @xvalor=0;
							return @xvalor
						end
				end
		
			 if(@nivelcuenta=14)
				begin
					set @xvalor=(SELECT sum(preopdebe-preophaber) 
								FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-006'
								,'4-1-05-007','4-1-05-009','4-1-05-011'
								,'4-1-05-015','4-1-05-017','4-1-05-019'
								,'4-1-05-025','4-1-05-027','4-1-05-033'
								,'4-1-05-034','4-1-05-037','4-1-05-041'
								,'4-1-05-051','4-1-05-055','4-1-05-099')
								AND Preopmes BETWEEN 00 AND CONVERT(INT, @mes)
								AND preopano=@ano AND preopcc like  @CCosto+'-%' and preopcc like @CCosto+'%' )
						if(@xvalor=0)
						begin 
								set @xvalor=0;
								return @xvalor
							end
				end


			if(@nivelcuenta=15)
				begin
					set @xvalor=(SELECT sum(preopdebe-preophaber)
								FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-028'
										,'4-1-05-029','4-1-05-030','4-1-05-032')
										AND Preopmes BETWEEN 00 AND CONVERT(INT, @mes)
										 AND preopano=@ano AND preopcc like @CCosto+'-%'
									 AND preopano='2019' AND preopcc like  @CCosto+'-%' )
								if(@xvalor=0)
								begin 
										set @xvalor=0
										return @xvalor
								end
					end
	     
		 
					 if(@nivelcuenta=16)
						begin	
							set @xvalor=(SELECT sum(preopdebe-preophaber)
								FROM CIS.softland.cwpreop 
								 WHERE PreopCta IN ('4-1-05-028','4-1-05-029'
								,'4-1-05-030','4-1-05-032')
								AND Preopmes between  00 and CONVERT(INT, @mes) 
								AND preopano=@ano AND preopcc like  @CCosto+'-%')
								if(@xvalor=0)
								begin 
									set @xvalor=0;
									return @xvalor
								end
					end
						
						
		end
	end	
	
end		

end		
return @xvalor;
end	
					
	/*			if @xvalor = NULL
set @xvalor = 0
return @xvalor

				END


				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '11-001'
					AND PreopCC = '11-%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN 00 AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
			END	
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN 00 AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '00' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				END
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '00' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
END



end	
if @xvalor = NULL
set @xvalor = 0
return @xvalor
END

					
		--	BEGIN
		--		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
		--		set @xvalor =
		--		(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = '11-001'
		--			AND PreopCC like '12-001%'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--		end
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '00' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END


			
		--ELSE
		--	BEGIN
		--		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
		--		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		--		set @xvalor = 
		--		(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = @CCosto
		--			AND PreopCC like @CCosto+'%'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--		end
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '01' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END
			

		--END

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		 set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]
									where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta 
									AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
			set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] 
								where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  
								AND bdsession = @bd  and ano = @ano)
			IF(@existeDist = 1)
			BEGIN 
			   if(@nivelcuenta=10)
								begin
									set @xvalor=
										(SELECT sum(preopdebe-preophaber) 
											FROM CIS.softland.cwpreop 
											WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND Preopmes 
											BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%' )
											set @xvalor = ((@xvalor*@porcentaje)/100)
								end
								if(@nivelcuenta=11)
									begin 
				
				 set @xvalor=(SELECT sum(preopdebe-preophaber) 
				 FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-051') AND Preopmes 
				 BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%')
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end

				if(@nivelcuenta=12)
				begin
				set @xvalor=(
				SELECT sum(preopdebe-preophaber) 
				FROM CIS.softland.cwpreop 
				WHERE PreopCta IN ('4-1-05-005') AND Preopmes 
				BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%' )
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end

			    if(@nivelcuenta=13)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-01-009')AND Preopmes
				 BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%')
			    set @xvalor = ((@xvalor*@porcentaje)/100)
				end
	           
			   if(@nivelcuenta=14)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-006'
						,'4-1-05-007'
						,'4-1-05-009'
						,'4-1-05-011'
						,'4-1-05-015'
						,'4-1-05-017'
						,'4-1-05-019'
						,'4-1-05-025'
						,'4-1-05-027'
						,'4-1-05-033'
						,'4-1-05-034'
						,'4-1-05-037'
						,'4-1-05-041'
						,'4-1-05-051'
						,'4-1-05-055'
						,'4-1-05-099'
						)AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND 
						preopano=@ano AND preopcc like '11-%')
										set @xvalor = ((@xvalor*@porcentaje)/100)
							end
							
			   if(@nivelcuenta=15)
					begin
					set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND @mes AND preopano=@ano AND preopcc like '11-%' AND 
						Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND 
						preopano='2019' AND preopcc like '11-%')
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end
				   if(@nivelcuenta=16)
						begin
						set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND
						 preopano=@ano AND preopcc like '11-%')
						set @xvalor = ((@xvalor*@porcentaje)/100)
				end
	END

	else
	BEGIN 						
				if(@nivelcuenta=10)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) 
				FROM CIS.softland.cwpreop 
				WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND 
				Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2) 
				AND preopano=@ano AND preopcc like @CCosto+'%' )
				end
		    	if(@nivelcuenta=11)
				begin 	
				 set @xvalor=(SELECT sum(preopdebe-preophaber) 
				 FROM CIS.softland.cwpreop 
				 WHERE PreopCta IN ('4-1-05-051') AND Preopmes 
				 BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like @CCosto+'%')
				end
				if(@nivelcuenta=12)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber)
				 FROM CIS.softland.cwpreop 
				 WHERE PreopCta IN ('4-1-05-005') 
				 AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2) 
				 AND preopano=@ano AND preopcc like @CCosto+'%' )
				
				end

			    if(@nivelcuenta=13)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-01-009')AND Preopmes 
				BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '@CCosto')
		end
	    if(@nivelcuenta=14)
     	begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-006'
						,'4-1-05-007'
						,'4-1-05-009'
						,'4-1-05-011'
						,'4-1-05-015'
						,'4-1-05-017'
						,'4-1-05-019'
						,'4-1-05-025'
						,'4-1-05-027'
						,'4-1-05-033'
						,'4-1-05-034'
						,'4-1-05-037'
						,'4-1-05-041'
						,'4-1-05-051'
						,'4-1-05-055'
						,'4-1-05-099'
						)AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2) 
						AND preopano=@ano AND preopcc like '@CCosto')
				end
			   if(@nivelcuenta=15)
				begin
				set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND @mes AND preopano=@ano AND preopcc like '@CCosto'
						 AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)
						 AND preopano='2019' AND preopcc like '@CCosto')
				end
	  		   if(@nivelcuenta=16)
			begin	
				set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)
						AND preopano=@ano AND preopcc like '@CCosto')
			    
				end
end
end

	
				--set @xvalor =
				--(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = '11-001'
		--			AND PreopCC = '11-001'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--	END	
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '01' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END


		--	END
		--ELSE
		--	BEGIN
		--		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
		--		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		--		set @xvalor = 
		--		(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = @CCosto
		--			AND PreopCC like @CCosto+'%'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--		END
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '00' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END
--END

	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				end
				--set @xvalor = '3'
				if(@nivelcuenta=17)
					begin
					set @xvalor = 
						(SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-001','4-1-05-002') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND PreopCC like '01-%' )						
				set @xvalor = ((@xvalor*@porcentaje)/100)
					end
				if(@nivelcuenta=18)
				begin
				set @xvalor = 
						(SELECT sum(preopdebe-preophaber) 
						FROM CIS.softland.cwpreop 
						WHERE preopcta IN
						 ('4-1-05-007',
						 '4-1-05-009',
						 '4-1-05-011',
						 '4-1-05-013',
						 '4-1-05-015',
						 '4-1-05-017',
						 '4-1-05-019',
						 '4-1-05-021',
						 '4-1-05-025',
						 '4-1-05-027',
						 '4-1-05-033',
						 '4-1-05-035',
						 '4-1-05-037',
						 '4-1-05-041',
						 '4-1-05-043',
						 '4-1-05-046',
						 '4-1-05-047',
						 '4-1-05-051',
						 '4-1-05-053',
						 '4-1-05-055',
						 '4-1-05-099',
						 '5-1-01-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103) 
						   AND preopano=@ano AND preopcc like '01-%' )
						   end
	if(@nivelcuenta=26)
				begin
				set @xvalor = 
					   (SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND preopcc like '01-%' )
				set @xvalor = ((@xvalor*@porcentaje)/100)
			end
	else
			if(@nivelcuenta=17)
					begin
					set @xvalor = 
						(SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-001','4-1-05-002') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND PreopCC like @CCosto )
		 		set @xvalor = ((@xvalor*@porcentaje)/100)
				end
				if(@nivelcuenta=18)
				begin
				set @xvalor = 
						(SELECT sum(preopdebe-preophaber) 
						FROM CIS.softland.cwpreop 
						WHERE preopcta IN
						 ('4-1-05-007',
						 '4-1-05-009',
						 '4-1-05-011',
						 '4-1-05-013',
						 '4-1-05-015',
						 '4-1-05-017',
						 '4-1-05-019',
						 '4-1-05-021',
						 '4-1-05-025',
						 '4-1-05-027',
						 '4-1-05-033',
						 '4-1-05-035',
						 '4-1-05-037',
						 '4-1-05-041',
						 '4-1-05-043',
						 '4-1-05-046',
						 '4-1-05-047',
						 '4-1-05-051',
						 '4-1-05-053',
						 '4-1-05-055',
						 '4-1-05-099',
						 '5-1-01-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103) 
						   AND preopano=@ano AND preopcc like @CCosto+'%' )
						   end
				if(@nivelcuenta=26)
					begin
					set @xvalor = 
					   (SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND preopcc like @CCosto+'%' )
					set @xvalor = ((@xvalor*@porcentaje)/100)
	end
end

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @tipocuenta = (select b.PCTIPO from CIS.softland.cwpreop a inner join cis.softland.cwpctas b on a.preopcta = pccodi 
		where a.preop_id =@IDPresupuesto and a.preopAno = @ano and a.preopcc like @CCosto +'%' and a.preopMes = @mes AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd))


		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	IF(@obtengoNivel = 0)
	BEGIN
		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
					set @xvalor = (@xvalor *-1)
					--set @xvalor = '123465798'
	END

END


END  

*/
GO
/****** Object:  UserDefinedFunction [dbo].[returnPPTOCIS2_RSP1]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnPPTOCIS2_RSP1](@ano varchar(20),@IDPresupuesto varchar(50),@CCosto varchar(20), @nivelCuenta varchar(20),@bd varchar(30),@mes varchar(6),@condicion int) 
returns float(50)
as
BEGIN
declare @xvalor float(50)
declare @xvalorDist float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float(50)
declare @obtengoNivel int
declare @existeSuma int
Declare @tipocuenta varchar(50)

set @obtengoNivel = (select idNivel from dscis.dbo.DS_nivelesEERR where idcuenta = @nivelCuenta AND bdsession = @bd)

--select * from dscis.dbo.DS_AgrupacionCuentas where idNivel = '5'
--select * from dscis.dbo.DS_nivelesEERR where idcuenta = '5'

IF(@condicion = 1)
BEGIN
set @existeDist = 
(
	--select * from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '13-001' AND idCuenta =  '5' AND valor <> '100' AND valor <> '0'
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta =  @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano
)
	BEGIN
--INICIO BLOQUE POR NIVEL
		IF(@obtengoNivel = 0)
			BEGIN
						set @existeDist = (select count(*) as existeDist 
											from [DSCIS].[dbo].[DS_DistribucionCC] 
											 where CodiCC = @CCosto and idCuenta = @nivelCuenta 
											 AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
						set @existeSuma = (select Suma 
											from [DSCIS].[dbo].[DS_DistribucionCC]
											where CodiCC = @CCosto and idCuenta = @nivelCuenta
											 AND bdsession = @bd and ano = @ano)
			IF(@existeDist = 1)
				BEGIN
								set @xvalorDist = (select valor
								 from [DSCIS].[dbo].[DS_DistribucionCC]
								   where CodiCC = @CCosto and idCuenta = @nivelCuenta
								    AND bdsession = @bd and ano = @ano)
								
								set @xvalor =
											(SELECT isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
											FROM  CIS.softland.cwpreop
											WHERE PreopAno = @ano
											AND Preop_id = @IDPresupuesto
											AND PreopCC = @CCosto
											AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
											(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
											)
											AND PreopMes = @mes
												)

									set @xvalor = ((@xvalor * @xvalorDist)/100)
				
							IF(@existeSuma > 0)
								BEGIN
									set @xvalorSuma = (SELECT isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
													FROM  CIS.softland.cwpreop
													WHERE PreopAno = @ano
													AND Preop_id = @IDPresupuesto
													AND PreopCC = @CCosto
													AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
													(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
													)
													AND PreopMes = @mes
													)
						
											set @xvalor = (@xvalor + @xvalorSuma)

									end

			end
	end

IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		set @porcentaje =(select valor as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
								
		IF(@existeDist = 1)
		begin 
		set @porcentaje =(select valor as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
			   if(@nivelcuenta=1)
						begin 
						set @xvalor = 
						(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
						WHERE PreopCta IN ('4-1-05-042') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
						AND preopano='2019' AND PreopCC  like '12-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
					end
					if(@nivelcuenta=2)
			 begin 
						set @xvalor = 
						(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
						WHERE PreopCta IN ('4-1-01-003','4-1-01-005') AND preopmes BETWEEN  00 and CONVERT(INT, @mes)
						AND preopano='2019' AND preopcc  like '12-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
				end
					if(@nivelcuenta=3)
					begin 
						set @xvalor =
							(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-042') AND preopmes between 00 and  CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC like '12-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
			       end


					if(@nivelcuenta=4)
					begin 
							set @xvalor =(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND preopcc  like '12-%' AND Preop_id='CIS 2019' )
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end


					if(@nivelCuenta=5)
					begin 
							set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN ('4-1-05-007','4-1-05-009',
							'4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019','4-1-05-021','4-1-05-023',
							'4-1-05-025','4-1-05-031','4-1-05-033','4-1-05-035','4-1-05-037','4-1-05-041',
							'4-1-05-043','4-1-05-046','4-1-05-047',
							'4-1-05-055','4-1-05-099'
								)   and preopano='2019' AND preopmes BETWEEN 00 and CONVERT(INT, @mes))
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end

				if(@nivelcuenta=6)
				begin 
							set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN('4-1-05-001','4-1-05-002') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano=@ano AND preopcc like '12-%'  AND Preop_id='CIS 2019')
						set @xvalor = ((@xvalor*@porcentaje)/100)
				end


				if(@nivelcuenta=7)
					begin 
						set @xvalor = (
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN (
						'4-1-05-007','4-1-05-009','4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019',
						'4-1-05-021','4-1-05-023','4-1-05-025','4-1-05-031','4-1-05-033','4-1-05-035',
						'4-1-05-037','4-1-05-041','4-1-05-043','4-1-05-046','4-1-05-047','4-1-05-055',
						'4-1-05-099'
						)   and preopano=@ano AND preopmes BETWEEN 00 AND 	CONVERT(INT, @mes) AND Preop_id='CIS 2019'	)	
						set @xvalor = ((@xvalor*@porcentaje)/100 )
			end
		
		if(@nivelcuenta=8)
    	begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-099') and preopmes between  00 AND
										CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc like '12-%' AND Preop_id='CIS 2019')
						set @xvalor = ((@xvalor*@porcentaje)/100)
			end

			if(@nivelcuenta=9)
				begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-010') and preopmes BETWEEN 00
										 AND CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc  like '12-%' AND Preop_id='CIS 2019' )
						set @xvalor = ((@xvalor*@porcentaje)/100)
		     	end
				end
      else if(@existeDist=0)
				begin
				  if(@nivelcuenta=1)
				begin 
							set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
											WHERE PreopCta IN ('4-1-05-042') AND preopmes BETWEEN 00
											AND CONVERT(INT, @mes) AND PreopCC  like @CCosto+'%'
											AND preopano='2019'  AND Preop_id='CIS 2019' )
								if(@xvalor=null)
									begin
											return 0;
									end
		end				
		if(@nivelcuenta=2)
				begin 
					set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
      								WHERE PreopCta IN ('4-1-01-003','4-1-01-005') AND preopmes BETWEEN  00 AND CONVERT(INT, @mes) 
									AND preopano='2019' AND PreopCC  like @CCosto+'%'AND Preop_id='CIS 2019' )
									if(@xvalor=null)
									begin
										return 0;
									end
									end
	  	if(@nivelcuenta=3)
				begin 
				set @xvalor =(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
			  				WHERE PreopCta IN ('4-1-05-042') AND preopmes BETWEEN  00
							AND CONVERT(INT, @mes) 
							AND preopano='2019' AND PreopCC  like @CCosto+'%'    AND Preop_id='CIS 2019' )
						if(@xvalor=null)
							begin
								return 0;
							end
			     end
    	if(@nivelcuenta=4)
					begin 
							set @xvalor =(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND preopmes BETWEEN 00 AND
							CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like @CCosto+'-%'   AND Preop_id='CIS 2019' )
							if(@xvalor=null)
							begin
								return 0;
							end
							end
							
		if(@nivelcuenta=5)
					begin 
				set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN ('4-1-05-007',
						'4-1-05-009','4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019',
						'4-1-05-021','4-1-05-023','4-1-05-025','4-1-05-031','4-1-05-033',
	                    '4-1-05-035','4-1-05-037','4-1-05-041','4-1-05-043','4-1-05-046',
						'4-1-05-047','4-1-05-055','4-1-05-099')   and preopano='2019' AND   preopmes  BETWEEN 00 and CONVERT(INT, @mes)   
						AND Preop_id='CIS 2019' and  preopcc like @CCosto+'%')
						if(@xvalor=null)
							begin
							return 0;
							end
						
				end
    	if(@nivelcuenta=6)
    		    begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
						WHERE PreopCta IN('4-1-05-001','4-1-05-002') AND preopmes between 00 and CONVERT(INT, @mes)
						AND preopano=@ano AND preopcc like @CCosto+'%'  AND Preop_id='CIS 2019' )
						if(@xvalor=null)
							begin
							return 0;
							end		
				end
		if(@nivelcuenta=7)
				begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN (
						'4-1-05-007','4-1-05-009','4-1-05-011','4-1-05-015','4-1-05-017',
						'4-1-05-019','4-1-05-021','4-1-05-023','4-1-05-025','4-1-05-031',
						'4-1-05-033','4-1-05-035','4-1-05-037','4-1-05-041','4-1-05-043',
						'4-1-05-046','4-1-05-047','4-1-05-055',
						'4-1-05-099') and preopano=@ano AND preopmes BETWEEN 00 and CONVERT(INT, @mes) and preopcc  like @CCosto+'%' and Preop_id='CIS 2019')
						if(@xvalor=null)
							begin
							return 0;
							end
						
	 			end


					if(@nivelcuenta=8)
					begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-099') and preopmes BETWEEN 00 and CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc  like @CCosto+'%' AND preop_id='CIS 2019')
						if(@xvalor=null)
							begin
								return 0;
							end

						end

						if(@nivelcuenta=9)
						begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-010') and preopmes BETWEEN 00 and CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc  like @CCosto+'%' AND Preop_id='CIS 2019')
										if(@xvalor=null)
							begin
								return 0;
							end

				end
								end
				


END

IF(@obtengoNivel = 2)
	BEGIN
			 set @existeDist = (select count(*) as existeDist 
								 from [DSCIS].[dbo].[DS_DistribucionCC]
								where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta 
								AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma 
							    	from [DSCIS].[dbo].[DS_DistribucionCC] 
							     	where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  
							    	AND bdsession = @bd  and ano = @ano)
				set @porcentaje=(select valor as existeDist
						    	 from [DSCIS].[dbo].[DS_DistribucionCC]
							    where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta 
							   AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
			
if(@existeSuma>0)
begin
				if(@nivelcuenta=10)
					begin 
							set @xvalor = 
							(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like '11-001' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
							set @xvalor=((@xvalor*@porcentaje)/100)

							   SET @xvalorsuma=(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like '11-001' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
								
								set @xvalor=((@xvalor*@porcentaje)/100)
								set @xvalor=@xvalor+@xvalorSuma;
					end
					
				if(@nivelcuenta=11)	 
					begin 
						set @xvalor =(SELECT sum(preopdebe-preophaber)
										 FROM CIS.softland.cwpreop
									WHERE PreopCta IN ('4-1-05-051') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
									AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
						
							set @xvalor=((@xvalor*@porcentaje)/100)

                SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
								 FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-051') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
								AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
								set @xvalor=((@xvalor*@porcentaje)/100)
								set @xvalor=@xvalor+@xvalorSuma;
					end
				 
			
				if(@nivelcuenta=12)	 
				begin 
						set @xvalor = 
							(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
							WHERE PreopCta IN ('4-1-05-005') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

					    SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
								 FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-005') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
								AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
								set @xvalor=((@xvalor*@porcentaje)/100)
								set @xvalor=@xvalor+@xvalorSuma;
				end
	
	
			if(@nivelcuenta=13)	 
				begin 
					set @xvalor = 
						(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
						WHERE PreopCta IN ('4-1-01-009') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
						AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

	                SET @xvalorsuma=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
						WHERE PreopCta IN ('4-1-01-009') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
						AND preopano='2019' AND PreopCC  like '11-%' AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
				end


			if(@nivelcuenta=14)	 
				begin 
					set @xvalor = 
							(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
							WHERE PreopCta IN ('4-1-05-006'
							,'4-1-05-007','4-1-05-009','4-1-05-011','4-1-05-015'
							,'4-1-05-017','4-1-05-019','4-1-05-025','4-1-05-027'
							,'4-1-05-033','4-1-05-034','4-1-05-037','4-1-05-041'
							,'4-1-05-051','4-1-05-055','4-1-05-099')
							 AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

				     SET @xvalorsuma=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-006','4-1-05-007','4-1-05-009'
								,'4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019'
								,'4-1-05-025','4-1-05-027','4-1-05-033','4-1-05-034'
								,'4-1-05-037','4-1-05-041','4-1-05-051','4-1-05-055'
								,'4-1-05-099') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
	     		end

				if(@nivelcuenta=15)	 
					begin 
									set @xvalor =(SELECT sum(preopdebe-preophaber) 
										FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-028','4-1-05-029',
										'4-1-05-030','4-1-05-032')
									    AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
										AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

							SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
										 FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-028','4-1-05-029','4-1-05-030','4-1-05-032')
										AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
										AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
										set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
					end
					
				
			 if(@nivelcuenta=16)	 
				begin 
					set @xvalor = 
									(SELECT sum(preopdebe-preophaber)
										 FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-028','4-1-05-029','4-1-05-030'
									 ,'4-1-05-032') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
									AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
				
								set @xvalor=((@xvalor*@porcentaje)/100)
				
							 SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
											 FROM CIS.softland.cwpreop
											WHERE PreopCta IN ('4-1-05-028','4-1-05-029',
											'4-1-05-030','4-1-05-032')
											 AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
											AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
			  end	
end				
			
			

			
	IF(@existeDist = 1)
		BEGIN 
			
			 if(@nivelcuenta=10)
				begin
						set @xvalor=
								(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like '11-001' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
						set @xvalor = ((@xvalor*@porcentaje)/100)							
				end
			
			
			if(@nivelcuenta=11)
					begin 
							set @xvalor=(SELECT sum(preopdebe-preophaber) 
										 FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-051')   and PreopCC=@CCosto+'-%'
										AND Preopmes BETWEEN 00 and CONVERT(INT, @mes) and PreopCC like '11-%' )
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end

		    if(@nivelcuenta=12)
			begin
							set @xvalor=(SELECT sum(preopdebe-preophaber)
										FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-005')
										and PreopCC like '11-%'AND Preopmes BETWEEN 00 and CONVERT(INT, @mes))
							set @xvalor = ((@xvalor*@porcentaje)/100)
			end

		   
		    if(@nivelcuenta=13)
			begin
							set @xvalor=(SELECT sum(preopdebe-preophaber) 
										FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-01-009')AND Preopmes
										BETWEEN 00 and CONVERT(INT, @mes) and preopcc like '11-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)
			end
	           
		   
		   if(@nivelcuenta=14)
		   	begin
			set @xvalor=(SELECT sum(preopdebe-preophaber) 
						FROM CIS.softland.cwpreop
						 WHERE PreopCta IN ('4-1-05-006','4-1-05-007','4-1-05-009',
									'4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019','4-1-05-025','4-1-05-027',
									'4-1-05-033','4-1-05-034','4-1-05-037','4-1-05-041','4-1-05-051','4-1-05-055'
									,'4-1-05-099')
						AND Preopmes BETWEEN 00 and CONVERT(INT, @mes) AND 
						preopano=@ano AND preopcc like '11-%')
						set @xvalor = ((@xvalor*@porcentaje)/100)
			end
			
							
			   if(@nivelcuenta=15)
		   	begin
					set @xvalor=(SELECT sum(preopdebe-preophaber) 
								FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-028','4-1-05-029','4-1-05-030','4-1-05-032')
								AND Preopmes BETWEEN 00 AND CONVERT(INT, @mes) AND preopano=@ano AND preopcc like '11-%' AND 
								Preopmes BETWEEN 00 and 03 and	
								preopano='2019' AND preopcc like '11-%')
					set @xvalor = ((@xvalor*@porcentaje)/100)
			end	
			
	         if(@nivelcuenta=16)
			begin
						set @xvalor=(SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop
						  WHERE PreopCta IN ('4-1-05-028'
						,'4-1-05-029','4-1-05-030','4-1-05-032')AND Preopmes BETWEEN 00 and CONVERT(INT, @mes) 
						and preopano='2019' AND preopcc like '11-%')
					set @xvalor = ((@xvalor*@porcentaje)/100)
			end
			
		
		end
else
		BEGIN 						
				if(@nivelcuenta=10)
					begin
							set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like @CCosto+'%' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
									
								if(@xvalor=0)
									begin 
										set @xvalor=0;
									return @xvalor
								end
					END
		    	
				
				if(@nivelcuenta=11)
					begin 	
					set @xvalor=(SELECT sum(preopdebe-preophaber) 
								FROM CIS.softland.cwpreop 
								WHERE PreopCta IN ('4-1-05-051') AND Preopmes 
								 BETWEEN 00 AND CONVERT(INT, @mes))
			       
						    if(@xvalor=0)
								begin 
								set @xvalor=0;
								return @xvalor;
							end
				end
			
				if(@nivelcuenta=12)
				begin
					set @xvalor=(SELECT sum(preopdebe-preophaber)
							FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-005') 
							AND Preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano=@ano AND preopcc like @CCosto+'%' )
				
						if(@xvalor=0)
						begin 
							set @xvalor=0;
						return @xvalor
						end
				end
			  
			    if(@nivelcuenta=13)
				begin
				set @xvalor=
							(SELECT sum(preopdebe-preophaber)
							FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-01-009')AND Preopmes 
							BETWEEN 00 and CONVERT(INT, @mes) and preopcc like @CCosto+'%' )
				
						if(@xvalor=0)
						begin 
							set @xvalor=0;
							return @xvalor
						end
				end
		
			 if(@nivelcuenta=14)
				begin
					set @xvalor=(SELECT sum(preopdebe-preophaber) 
								FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-006'
								,'4-1-05-007','4-1-05-009','4-1-05-011'
								,'4-1-05-015','4-1-05-017','4-1-05-019'
								,'4-1-05-025','4-1-05-027','4-1-05-033'
								,'4-1-05-034','4-1-05-037','4-1-05-041'
								,'4-1-05-051','4-1-05-055','4-1-05-099')
								AND Preopmes BETWEEN 00 AND CONVERT(INT, @mes)
								AND preopano=@ano AND preopcc like  @CCosto+'-%' and preopcc like @CCosto+'%' )
						if(@xvalor=0)
						begin 
								set @xvalor=0;
								return @xvalor
							end
				end


			if(@nivelcuenta=15)
				begin
					set @xvalor=(SELECT sum(preopdebe-preophaber)
								FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-028'
										,'4-1-05-029','4-1-05-030','4-1-05-032')
										AND Preopmes BETWEEN 00 AND CONVERT(INT, @mes)
										 AND preopano=@ano AND preopcc like @CCosto+'-%'
									 AND preopano='2019' AND preopcc like  @CCosto+'-%' )
								if(@xvalor=0)
								begin 
										set @xvalor=0
										return @xvalor
								end
					end
	     
		 
					 if(@nivelcuenta=16)
						begin	
							set @xvalor=(SELECT sum(preopdebe-preophaber)
								FROM CIS.softland.cwpreop 
								 WHERE PreopCta IN ('4-1-05-028','4-1-05-029'
								,'4-1-05-030','4-1-05-032')
								AND Preopmes between  00 and CONVERT(INT, @mes) 
								AND preopano=@ano AND preopcc like  @CCosto+'-%')
								if(@xvalor=0)
								begin 
									set @xvalor=0;
									return @xvalor
								end
					end
						
						
		end
	end	
	
end		

end		
return @xvalor;
end	
					
	/*			if @xvalor = NULL
set @xvalor = 0
return @xvalor

				END


				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '11-001'
					AND PreopCC = '11-%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN 00 AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
			END	
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN 00 AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '00' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				END
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '00' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
END



end	
if @xvalor = NULL
set @xvalor = 0
return @xvalor
END

					
		--	BEGIN
		--		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
		--		set @xvalor =
		--		(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = '11-001'
		--			AND PreopCC like '12-001%'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--		end
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '00' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END


			
		--ELSE
		--	BEGIN
		--		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
		--		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		--		set @xvalor = 
		--		(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = @CCosto
		--			AND PreopCC like @CCosto+'%'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--		end
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '01' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END
			

		--END

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		 set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]
									where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta 
									AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
			set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] 
								where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  
								AND bdsession = @bd  and ano = @ano)
			IF(@existeDist = 1)
			BEGIN 
			   if(@nivelcuenta=10)
								begin
									set @xvalor=
										(SELECT sum(preopdebe-preophaber) 
											FROM CIS.softland.cwpreop 
											WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND Preopmes 
											BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%' )
											set @xvalor = ((@xvalor*@porcentaje)/100)
								end
								if(@nivelcuenta=11)
									begin 
				
				 set @xvalor=(SELECT sum(preopdebe-preophaber) 
				 FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-051') AND Preopmes 
				 BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%')
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end

				if(@nivelcuenta=12)
				begin
				set @xvalor=(
				SELECT sum(preopdebe-preophaber) 
				FROM CIS.softland.cwpreop 
				WHERE PreopCta IN ('4-1-05-005') AND Preopmes 
				BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%' )
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end

			    if(@nivelcuenta=13)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-01-009')AND Preopmes
				 BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%')
			    set @xvalor = ((@xvalor*@porcentaje)/100)
				end
	           
			   if(@nivelcuenta=14)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-006'
						,'4-1-05-007'
						,'4-1-05-009'
						,'4-1-05-011'
						,'4-1-05-015'
						,'4-1-05-017'
						,'4-1-05-019'
						,'4-1-05-025'
						,'4-1-05-027'
						,'4-1-05-033'
						,'4-1-05-034'
						,'4-1-05-037'
						,'4-1-05-041'
						,'4-1-05-051'
						,'4-1-05-055'
						,'4-1-05-099'
						)AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND 
						preopano=@ano AND preopcc like '11-%')
										set @xvalor = ((@xvalor*@porcentaje)/100)
							end
							
			   if(@nivelcuenta=15)
					begin
					set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND @mes AND preopano=@ano AND preopcc like '11-%' AND 
						Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND 
						preopano='2019' AND preopcc like '11-%')
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end
				   if(@nivelcuenta=16)
						begin
						set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND
						 preopano=@ano AND preopcc like '11-%')
						set @xvalor = ((@xvalor*@porcentaje)/100)
				end
	END

	else
	BEGIN 						
				if(@nivelcuenta=10)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) 
				FROM CIS.softland.cwpreop 
				WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND 
				Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2) 
				AND preopano=@ano AND preopcc like @CCosto+'%' )
				end
		    	if(@nivelcuenta=11)
				begin 	
				 set @xvalor=(SELECT sum(preopdebe-preophaber) 
				 FROM CIS.softland.cwpreop 
				 WHERE PreopCta IN ('4-1-05-051') AND Preopmes 
				 BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like @CCosto+'%')
				end
				if(@nivelcuenta=12)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber)
				 FROM CIS.softland.cwpreop 
				 WHERE PreopCta IN ('4-1-05-005') 
				 AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2) 
				 AND preopano=@ano AND preopcc like @CCosto+'%' )
				
				end

			    if(@nivelcuenta=13)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-01-009')AND Preopmes 
				BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '@CCosto')
		end
	    if(@nivelcuenta=14)
     	begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-006'
						,'4-1-05-007'
						,'4-1-05-009'
						,'4-1-05-011'
						,'4-1-05-015'
						,'4-1-05-017'
						,'4-1-05-019'
						,'4-1-05-025'
						,'4-1-05-027'
						,'4-1-05-033'
						,'4-1-05-034'
						,'4-1-05-037'
						,'4-1-05-041'
						,'4-1-05-051'
						,'4-1-05-055'
						,'4-1-05-099'
						)AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2) 
						AND preopano=@ano AND preopcc like '@CCosto')
				end
			   if(@nivelcuenta=15)
				begin
				set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND @mes AND preopano=@ano AND preopcc like '@CCosto'
						 AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)
						 AND preopano='2019' AND preopcc like '@CCosto')
				end
	  		   if(@nivelcuenta=16)
			begin	
				set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)
						AND preopano=@ano AND preopcc like '@CCosto')
			    
				end
end
end

	
				--set @xvalor =
				--(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = '11-001'
		--			AND PreopCC = '11-001'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--	END	
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '01' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END


		--	END
		--ELSE
		--	BEGIN
		--		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
		--		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		--		set @xvalor = 
		--		(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = @CCosto
		--			AND PreopCC like @CCosto+'%'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--		END
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '00' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END
--END

	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				end
				--set @xvalor = '3'
				if(@nivelcuenta=17)
					begin
					set @xvalor = 
						(SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-001','4-1-05-002') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND PreopCC like '01-%' )						
				set @xvalor = ((@xvalor*@porcentaje)/100)
					end
				if(@nivelcuenta=18)
				begin
				set @xvalor = 
						(SELECT sum(preopdebe-preophaber) 
						FROM CIS.softland.cwpreop 
						WHERE preopcta IN
						 ('4-1-05-007',
						 '4-1-05-009',
						 '4-1-05-011',
						 '4-1-05-013',
						 '4-1-05-015',
						 '4-1-05-017',
						 '4-1-05-019',
						 '4-1-05-021',
						 '4-1-05-025',
						 '4-1-05-027',
						 '4-1-05-033',
						 '4-1-05-035',
						 '4-1-05-037',
						 '4-1-05-041',
						 '4-1-05-043',
						 '4-1-05-046',
						 '4-1-05-047',
						 '4-1-05-051',
						 '4-1-05-053',
						 '4-1-05-055',
						 '4-1-05-099',
						 '5-1-01-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103) 
						   AND preopano=@ano AND preopcc like '01-%' )
						   end
	if(@nivelcuenta=26)
				begin
				set @xvalor = 
					   (SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND preopcc like '01-%' )
				set @xvalor = ((@xvalor*@porcentaje)/100)
			end
	else
			if(@nivelcuenta=17)
					begin
					set @xvalor = 
						(SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-001','4-1-05-002') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND PreopCC like @CCosto )
		 		set @xvalor = ((@xvalor*@porcentaje)/100)
				end
				if(@nivelcuenta=18)
				begin
				set @xvalor = 
						(SELECT sum(preopdebe-preophaber) 
						FROM CIS.softland.cwpreop 
						WHERE preopcta IN
						 ('4-1-05-007',
						 '4-1-05-009',
						 '4-1-05-011',
						 '4-1-05-013',
						 '4-1-05-015',
						 '4-1-05-017',
						 '4-1-05-019',
						 '4-1-05-021',
						 '4-1-05-025',
						 '4-1-05-027',
						 '4-1-05-033',
						 '4-1-05-035',
						 '4-1-05-037',
						 '4-1-05-041',
						 '4-1-05-043',
						 '4-1-05-046',
						 '4-1-05-047',
						 '4-1-05-051',
						 '4-1-05-053',
						 '4-1-05-055',
						 '4-1-05-099',
						 '5-1-01-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103) 
						   AND preopano=@ano AND preopcc like @CCosto+'%' )
						   end
				if(@nivelcuenta=26)
					begin
					set @xvalor = 
					   (SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND preopcc like @CCosto+'%' )
					set @xvalor = ((@xvalor*@porcentaje)/100)
	end
end

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @tipocuenta = (select b.PCTIPO from CIS.softland.cwpreop a inner join cis.softland.cwpctas b on a.preopcta = pccodi 
		where a.preop_id =@IDPresupuesto and a.preopAno = @ano and a.preopcc like @CCosto +'%' and a.preopMes = @mes AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd))


		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	IF(@obtengoNivel = 0)
	BEGIN
		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
					set @xvalor = (@xvalor *-1)
					--set @xvalor = '123465798'
	END

END


END  

*/
GO
/****** Object:  UserDefinedFunction [dbo].[returnPPTOCIS2RESPALDO]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnPPTOCIS2RESPALDO](@ano varchar(20),@IDPresupuesto varchar(50),@CCosto varchar(20), @nivelCuenta varchar(20),@bd varchar(30),@mes varchar(6),@condicion int) 
returns float(50)
as
BEGIN
declare @xvalor float(50)
declare @xvalorDist float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float(50)
declare @obtengoNivel int
declare @existeSuma int
Declare @tipocuenta varchar(50)


set @obtengoNivel = (select idNivel from dscis.dbo.DS_nivelesEERR where idcuenta = @nivelCuenta AND bdsession = @bd)

--select * from dscis.dbo.DS_AgrupacionCuentas where idNivel = '5'
--select * from dscis.dbo.DS_nivelesEERR where idcuenta = '5'

IF(@condicion = 0)
begin
set @existeDist = 
(
	--select * from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '13-001' AND idCuenta =  '5' AND valor <> '100' AND valor <> '0'
	select valor as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta =  @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano
)
	BEGIN


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 0)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '12-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '11-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
--@nivelCuenta

				IF(@nivelCuenta = 21 OR @nivelCuenta = 22 OR @nivelCuenta = 25)
				BEGIN
					set @xvalor = (@xvalor *-1)
				END
				

				IF(@nivelCuenta = 20)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

				IF(@nivelCuenta = 24)
				BEGIN
					IF(@xvalor >0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano )
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		
		set @tipocuenta = (select b.PCTIPO from CIS.softland.cwpreop a inner join cis.softland.cwpctas b on a.preopcta = pccodi 
		where a.preop_id =@IDPresupuesto and a.preopAno = @ano and a.preopcc like @CCosto+'%' and a.preopMes = @mes AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd))

		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	


	END

END
ELSE
BEGIN
/*
set @xvalor = 
(
	SELECT 
	isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
	FROM  CIS.softland.cwpreop
	WHERE PreopAno = @ano
	AND Preop_id = @IDPresupuesto
	AND PreopCC = @CCosto
	AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
	)
	AND PreopMes BETWEEN '01' AND @mes
)

set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto and idCuenta = @nivelCuenta)

set @xvalor = ((@xvalor * @porcentaje)/100)
*/

IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '12-001'
					AND PreopCC like '12%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND PreopCC = '12-001'
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel  AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			--set @xvalor = '123465798'

			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '11-001'
					AND PreopCC like '11%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND PreopCC = '11-001'
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
				     AND PreopCC = '01-001'
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @tipocuenta = (select b.PCTIPO from CIS.softland.cwpreop a inner join cis.softland.cwpctas b on a.preopcta = pccodi 
		where a.preop_id =@IDPresupuesto and a.preopAno = @ano and a.preopcc like @CCosto +'%' and a.preopMes = @mes AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd))


		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	IF(@obtengoNivel = 0)
	BEGIN
		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC =  @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
					set @xvalor = (@xvalor *-1)
					--set @xvalor = '123465798'
	END

END


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnPPTOCISRESPALDOCORRECTO]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnPPTOCISRESPALDOCORRECTO](@ano varchar(20),@IDPresupuesto varchar(50),@CCosto varchar(20), @nivelCuenta varchar(20),@bd varchar(30),@mes varchar(6),@condicion int) 
returns float(50)
as
BEGIN
declare @xvalor float(50)
declare @xvalorDist float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float(50)
declare @obtengoNivel int
declare @existeSuma int
Declare @tipocuenta varchar(50)

set @obtengoNivel = (select idNivel from dscis.dbo.DS_nivelesEERR where idcuenta = @nivelCuenta AND bdsession = @bd)

--select * from dscis.dbo.DS_AgrupacionCuentas where idNivel = '5'
--select * from dscis.dbo.DS_nivelesEERR where idcuenta = '5'

IF(@condicion = 1)
BEGIN
set @existeDist = 
(
	--select * from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '13-001' AND idCuenta =  '5' AND valor <> '100' AND valor <> '0'
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta =  @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano
)
	BEGIN
--INICIO BLOQUE POR NIVEL
		IF(@obtengoNivel = 0)
			BEGIN
						set @existeDist = (select count(*) as existeDist 
											from [DSCIS].[dbo].[DS_DistribucionCC] 
											 where CodiCC = @CCosto and idCuenta = @nivelCuenta 
											 AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
						set @existeSuma = (select Suma 
											from [DSCIS].[dbo].[DS_DistribucionCC]
											where CodiCC = @CCosto and idCuenta = @nivelCuenta
											 AND bdsession = @bd and ano = @ano)
			IF(@existeDist = 1)
				BEGIN
								set @xvalorDist = (select valor
								 from [DSCIS].[dbo].[DS_DistribucionCC]
								   where CodiCC = @CCosto and idCuenta = @nivelCuenta
								    AND bdsession = @bd and ano = @ano)
								
								set @xvalor =
											(SELECT isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
											FROM  CIS.softland.cwpreop
											WHERE PreopAno = @ano
											AND Preop_id = @IDPresupuesto
											AND PreopCC = @CCosto
											AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
											(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
											)
											AND PreopMes = @mes
												)

									set @xvalor = ((@xvalor * @xvalorDist)/100)
				
							IF(@existeSuma > 0)
								BEGIN
									set @xvalorSuma = (SELECT isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
													FROM  CIS.softland.cwpreop
													WHERE PreopAno = @ano
													AND Preop_id = @IDPresupuesto
													AND PreopCC = @CCosto
													AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
													(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
													)
													AND PreopMes = @mes
													)
						
											set @xvalor = (@xvalor + @xvalorSuma)

									end

			end
	end

IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		set @porcentaje =(select valor as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
								
		IF(@existeDist = 1)
		begin 
		set @porcentaje =(select valor as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
			   if(@nivelcuenta=1)
						begin 
						set @xvalor = 
						(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
						WHERE PreopCta IN ('4-1-05-042') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
						AND preopano='2019' AND PreopCC  like '12-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
					end
					if(@nivelcuenta=2)
			 begin 
						set @xvalor = 
						(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
						WHERE PreopCta IN ('4-1-01-003','4-1-01-005') AND preopmes BETWEEN  00 and CONVERT(INT, @mes)
						AND preopano='2019' AND preopcc  like '12-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
				end
					if(@nivelcuenta=3)
					begin 
						set @xvalor =
							(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-042') AND preopmes between 00 and  CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC like '12-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
			       end


					if(@nivelcuenta=4)
					begin 
							set @xvalor =(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND preopcc  like '12-%' AND Preop_id='CIS 2019' )
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end


					if(@nivelCuenta=5)
					begin 
							set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN ('4-1-05-007','4-1-05-009',
							'4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019','4-1-05-021','4-1-05-023',
							'4-1-05-025','4-1-05-031','4-1-05-033','4-1-05-035','4-1-05-037','4-1-05-041',
							'4-1-05-043','4-1-05-046','4-1-05-047',
							'4-1-05-055','4-1-05-099'
								)   and preopano='2019' AND preopmes BETWEEN 00 and CONVERT(INT, @mes))
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end

				if(@nivelcuenta=6)
				begin 
							set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN('4-1-05-001','4-1-05-002') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano=@ano AND preopcc like '12-%'  AND Preop_id='CIS 2019')
						set @xvalor = ((@xvalor*@porcentaje)/100)
				end


				if(@nivelcuenta=7)
					begin 
						set @xvalor = (
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN (
						'4-1-05-007','4-1-05-009','4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019',
						'4-1-05-021','4-1-05-023','4-1-05-025','4-1-05-031','4-1-05-033','4-1-05-035',
						'4-1-05-037','4-1-05-041','4-1-05-043','4-1-05-046','4-1-05-047','4-1-05-055',
						'4-1-05-099'
						)   and preopano=@ano AND preopmes BETWEEN 00 AND 	CONVERT(INT, @mes) AND Preop_id='CIS 2019'	)	
						set @xvalor = ((@xvalor*@porcentaje)/100 )
			end
		
		if(@nivelcuenta=8)
    	begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-099') and preopmes between  00 AND
										CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc like '12-%' AND Preop_id='CIS 2019')
						set @xvalor = ((@xvalor*@porcentaje)/100)
			end

			if(@nivelcuenta=9)
				begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-010') and preopmes BETWEEN 00
										 AND CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc  like '12-%' AND Preop_id='CIS 2019' )
						set @xvalor = ((@xvalor*@porcentaje)/100)
		     	end
				end
      else if(@existeDist=0)
				begin
				  if(@nivelcuenta=1)
				begin 
							set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
											WHERE PreopCta IN ('4-1-05-042') AND preopmes BETWEEN 00
											AND CONVERT(INT, @mes) AND PreopCC  like @CCosto+'%'
											AND preopano='2019'  AND Preop_id='CIS 2019' )
								if(@xvalor=null)
									begin
											return 0;
									end
		end				
		if(@nivelcuenta=2)
				begin 
					set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
      								WHERE PreopCta IN ('4-1-01-003','4-1-01-005') AND preopmes BETWEEN  00 AND CONVERT(INT, @mes) 
									AND preopano='2019' AND PreopCC  like @CCosto+'%'AND Preop_id='CIS 2019' )
									if(@xvalor=null)
									begin
										return 0;
									end
									end
	  	if(@nivelcuenta=3)
				begin 
				set @xvalor =(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
			  				WHERE PreopCta IN ('4-1-05-042') AND preopmes BETWEEN  00
							AND CONVERT(INT, @mes) 
							AND preopano='2019' AND PreopCC  like @CCosto+'%'    AND Preop_id='CIS 2019' )
						if(@xvalor=null)
							begin
								return 0;
							end
			     end
    	if(@nivelcuenta=4)
					begin 
							set @xvalor =(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND preopmes BETWEEN 00 AND
							CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like @CCosto+'-%'   AND Preop_id='CIS 2019' )
							if(@xvalor=null)
							begin
								return 0;
							end
							end
							
		if(@nivelcuenta=5)
					begin 
				set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN ('4-1-05-007',
						'4-1-05-009','4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019',
						'4-1-05-021','4-1-05-023','4-1-05-025','4-1-05-031','4-1-05-033',
	                    '4-1-05-035','4-1-05-037','4-1-05-041','4-1-05-043','4-1-05-046',
						'4-1-05-047','4-1-05-055','4-1-05-099')   and preopano='2019' AND   preopmes  BETWEEN 00 and CONVERT(INT, @mes)   
						AND Preop_id='CIS 2019' and  preopcc like @CCosto+'%')
						if(@xvalor=null)
							begin
							return 0;
							end
						
				end
    	if(@nivelcuenta=6)
    		    begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
						WHERE PreopCta IN('4-1-05-001','4-1-05-002') AND preopmes between 00 and CONVERT(INT, @mes)
						AND preopano=@ano AND preopcc like @CCosto+'%'  AND Preop_id='CIS 2019' )
						if(@xvalor=null)
							begin
							return 0;
							end		
				end
		if(@nivelcuenta=7)
				begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop  WHERE PreopCta IN (
						'4-1-05-007','4-1-05-009','4-1-05-011','4-1-05-015','4-1-05-017',
						'4-1-05-019','4-1-05-021','4-1-05-023','4-1-05-025','4-1-05-031',
						'4-1-05-033','4-1-05-035','4-1-05-037','4-1-05-041','4-1-05-043',
						'4-1-05-046','4-1-05-047','4-1-05-055',
						'4-1-05-099') and preopano=@ano AND preopmes BETWEEN 00 and CONVERT(INT, @mes) and preopcc  like @CCosto+'%' and Preop_id='CIS 2019')
						if(@xvalor=null)
							begin
							return 0;
							end
						
	 			end


					if(@nivelcuenta=8)
					begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-099') and preopmes BETWEEN 00 and CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc  like @CCosto+'%' AND preop_id='CIS 2019')
						if(@xvalor=null)
							begin
								return 0;
							end

						end

						if(@nivelcuenta=9)
						begin 
						set @xvalor = (SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop 
										WHERE PreopCta IN('4-1-01-010') and preopmes BETWEEN 00 and CONVERT(INT, @mes) AND 
										preopano=@ano AND preopcc  like @CCosto+'%' AND Preop_id='CIS 2019')
										if(@xvalor=null)
							begin
								return 0;
							end

				end
								end
				


END

IF(@obtengoNivel = 2)
	BEGIN
			 set @existeDist = (select count(*) as existeDist 
								 from [DSCIS].[dbo].[DS_DistribucionCC]
								where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta 
								AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma 
							    	from [DSCIS].[dbo].[DS_DistribucionCC] 
							     	where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  
							    	AND bdsession = @bd  and ano = @ano)
				set @porcentaje=(select valor as existeDist
						    	 from [DSCIS].[dbo].[DS_DistribucionCC]
							    where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta 
							   AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
			
if(@existeSuma>0)
begin
				if(@nivelcuenta=10)
					begin 
							set @xvalor = 
							(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like '11-001' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
							set @xvalor=((@xvalor*@porcentaje)/100)

							   SET @xvalorsuma=(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like '11-001' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
								
								set @xvalor=((@xvalor*@porcentaje)/100)
								set @xvalor=@xvalor+@xvalorSuma;
					end
					
				if(@nivelcuenta=11)	 
					begin 
						set @xvalor =(SELECT sum(preopdebe-preophaber)
										 FROM CIS.softland.cwpreop
									WHERE PreopCta IN ('4-1-05-051') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
									AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
						
							set @xvalor=((@xvalor*@porcentaje)/100)

                SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
								 FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-051') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
								AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
								set @xvalor=((@xvalor*@porcentaje)/100)
								set @xvalor=@xvalor+@xvalorSuma;
					end
				 
			
				if(@nivelcuenta=12)	 
				begin 
						set @xvalor = 
							(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
							WHERE PreopCta IN ('4-1-05-005') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

					    SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
								 FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-005') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
								AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
								set @xvalor=((@xvalor*@porcentaje)/100)
								set @xvalor=@xvalor+@xvalorSuma;
				end
	
	
			if(@nivelcuenta=13)	 
				begin 
					set @xvalor = 
						(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
						WHERE PreopCta IN ('4-1-01-009') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
						AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

	                SET @xvalorsuma=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
						WHERE PreopCta IN ('4-1-01-009') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
						AND preopano='2019' AND PreopCC  like '11-%' AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
				end


			if(@nivelcuenta=14)	 
				begin 
					set @xvalor = 
							(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
							WHERE PreopCta IN ('4-1-05-006'
							,'4-1-05-007','4-1-05-009','4-1-05-011','4-1-05-015'
							,'4-1-05-017','4-1-05-019','4-1-05-025','4-1-05-027'
							,'4-1-05-033','4-1-05-034','4-1-05-037','4-1-05-041'
							,'4-1-05-051','4-1-05-055','4-1-05-099')
							 AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

				     SET @xvalorsuma=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-006','4-1-05-007','4-1-05-009'
								,'4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019'
								,'4-1-05-025','4-1-05-027','4-1-05-033','4-1-05-034'
								,'4-1-05-037','4-1-05-041','4-1-05-051','4-1-05-055'
								,'4-1-05-099') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
	     		end

				if(@nivelcuenta=15)	 
					begin 
									set @xvalor =(SELECT sum(preopdebe-preophaber) 
										FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-028','4-1-05-029',
										'4-1-05-030','4-1-05-032')
									    AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
										AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)

							SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
										 FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-028','4-1-05-029','4-1-05-030','4-1-05-032')
										AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
										AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
										set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
					end
					
				
			 if(@nivelcuenta=16)	 
				begin 
					set @xvalor = 
									(SELECT sum(preopdebe-preophaber)
										 FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-028','4-1-05-029','4-1-05-030'
									 ,'4-1-05-032') AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
									AND preopano='2019' AND PreopCC  like @CCosto+'%'  AND Preop_id='CIS 2019')
				
								set @xvalor=((@xvalor*@porcentaje)/100)
				
							 SET @xvalorsuma=(SELECT sum(preopdebe-preophaber)
											 FROM CIS.softland.cwpreop
											WHERE PreopCta IN ('4-1-05-028','4-1-05-029',
											'4-1-05-030','4-1-05-032')
											 AND preopmes BETWEEN 00 and CONVERT(INT, @mes)
											AND preopano='2019' AND PreopCC  like '11-%'  AND Preop_id='CIS 2019')
							set @xvalor=((@xvalor*@porcentaje)/100)
							set @xvalor=@xvalor+@xvalorSuma;
			  end	
end				
			
			

			
	IF(@existeDist = 1)
		BEGIN 
			
			 if(@nivelcuenta=10)
				begin
						set @xvalor=
								(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like '11-001' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
						set @xvalor = ((@xvalor*@porcentaje)/100)							
				end
			
			
			if(@nivelcuenta=11)
					begin 
							set @xvalor=(SELECT sum(preopdebe-preophaber) 
										 FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-051')   and PreopCC=@CCosto+'-%'
										AND Preopmes BETWEEN 00 and CONVERT(INT, @mes) and PreopCC like '11-%' )
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end

		    if(@nivelcuenta=12)
			begin
							set @xvalor=(SELECT sum(preopdebe-preophaber)
										FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-05-005')
										and PreopCC like '11-%'AND Preopmes BETWEEN 00 and CONVERT(INT, @mes))
							set @xvalor = ((@xvalor*@porcentaje)/100)
			end

		   
		    if(@nivelcuenta=13)
			begin
							set @xvalor=(SELECT sum(preopdebe-preophaber) 
										FROM CIS.softland.cwpreop
										WHERE PreopCta IN ('4-1-01-009')AND Preopmes
										BETWEEN 00 and CONVERT(INT, @mes) and preopcc like '11-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)
			end
	           
		   
		   if(@nivelcuenta=14)
		   	begin
			set @xvalor=(SELECT sum(preopdebe-preophaber) 
						FROM CIS.softland.cwpreop
						 WHERE PreopCta IN ('4-1-05-006','4-1-05-007','4-1-05-009',
									'4-1-05-011','4-1-05-015','4-1-05-017','4-1-05-019','4-1-05-025','4-1-05-027',
									'4-1-05-033','4-1-05-034','4-1-05-037','4-1-05-041','4-1-05-051','4-1-05-055'
									,'4-1-05-099')
						AND Preopmes BETWEEN 00 and CONVERT(INT, @mes) AND 
						preopano=@ano AND preopcc like '11-%')
						set @xvalor = ((@xvalor*@porcentaje)/100)
			end
			
							
			   if(@nivelcuenta=15)
		   	begin
					set @xvalor=(SELECT sum(preopdebe-preophaber) 
								FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-028','4-1-05-029','4-1-05-030','4-1-05-032')
								AND Preopmes BETWEEN 00 AND CONVERT(INT, @mes) AND preopano=@ano AND preopcc like '11-%' AND 
								Preopmes BETWEEN 00 and 03 and	
								preopano='2019' AND preopcc like '11-%')
					set @xvalor = ((@xvalor*@porcentaje)/100)
			end	
			
	         if(@nivelcuenta=16)
			begin
						set @xvalor=(SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop
						  WHERE PreopCta IN ('4-1-05-028'
						,'4-1-05-029','4-1-05-030','4-1-05-032')AND Preopmes BETWEEN 00 and CONVERT(INT, @mes) 
						and preopano='2019' AND preopcc like '11-%')
					set @xvalor = ((@xvalor*@porcentaje)/100)
			end
			
		
		end
else
		BEGIN 						
				if(@nivelcuenta=10)
					begin
							set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.SOFTLAND.CWPREOP where preopcc like @CCosto+'%' and preopano='2019' and preopcta in ('4-1-05-001','4-1-05-002') and preopmes between 00 and CONVERT(INT, @mes))
									
								if(@xvalor=0)
									begin 
										set @xvalor=0;
									return @xvalor
								end
					END
		    	
				
				if(@nivelcuenta=11)
					begin 	
					set @xvalor=(SELECT sum(preopdebe-preophaber) 
								FROM CIS.softland.cwpreop 
								WHERE PreopCta IN ('4-1-05-051') AND Preopmes 
								 BETWEEN 00 AND CONVERT(INT, @mes))
			       
						    if(@xvalor=0)
								begin 
								set @xvalor=0;
								return @xvalor;
							end
				end
			
				if(@nivelcuenta=12)
				begin
					set @xvalor=(SELECT sum(preopdebe-preophaber)
							FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-05-005') 
							AND Preopmes BETWEEN 00 and CONVERT(INT, @mes)
							AND preopano=@ano AND preopcc like @CCosto+'%' )
				
						if(@xvalor=0)
						begin 
							set @xvalor=0;
						return @xvalor
						end
				end
			  
			    if(@nivelcuenta=13)
				begin
				set @xvalor=
							(SELECT sum(preopdebe-preophaber)
							FROM CIS.softland.cwpreop 
							WHERE PreopCta IN ('4-1-01-009')AND Preopmes 
							BETWEEN 00 and CONVERT(INT, @mes) and preopcc like @CCosto+'%' )
				
						if(@xvalor=0)
						begin 
							set @xvalor=0;
							return @xvalor
						end
				end
		
			 if(@nivelcuenta=14)
				begin
					set @xvalor=(SELECT sum(preopdebe-preophaber) 
								FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-006'
								,'4-1-05-007','4-1-05-009','4-1-05-011'
								,'4-1-05-015','4-1-05-017','4-1-05-019'
								,'4-1-05-025','4-1-05-027','4-1-05-033'
								,'4-1-05-034','4-1-05-037','4-1-05-041'
								,'4-1-05-051','4-1-05-055','4-1-05-099')
								AND Preopmes BETWEEN 00 AND CONVERT(INT, @mes)
								AND preopano=@ano AND preopcc like  @CCosto+'-%' and preopcc like @CCosto+'%' )
						if(@xvalor=0)
						begin 
								set @xvalor=0;
								return @xvalor
							end
				end


			if(@nivelcuenta=15)
				begin
					set @xvalor=(SELECT sum(preopdebe-preophaber)
								FROM CIS.softland.cwpreop
								WHERE PreopCta IN ('4-1-05-028'
										,'4-1-05-029','4-1-05-030','4-1-05-032')
										AND Preopmes BETWEEN 00 AND CONVERT(INT, @mes)
										 AND preopano=@ano AND preopcc like @CCosto+'-%'
									 AND preopano='2019' AND preopcc like  @CCosto+'-%' )
								if(@xvalor=0)
								begin 
										set @xvalor=0
										return @xvalor
								end
					end
	     
		 
					 if(@nivelcuenta=16)
						begin	
							set @xvalor=(SELECT sum(preopdebe-preophaber)
								FROM CIS.softland.cwpreop 
								 WHERE PreopCta IN ('4-1-05-028','4-1-05-029'
								,'4-1-05-030','4-1-05-032')
								AND Preopmes between  00 and CONVERT(INT, @mes) 
								AND preopano=@ano AND preopcc like  @CCosto+'-%')
								if(@xvalor=0)
								begin 
									set @xvalor=0;
									return @xvalor
								end
					end
						
						
		end
	end	
	
end		

end		
return @xvalor;
end	
					
	/*			if @xvalor = NULL
set @xvalor = 0
return @xvalor

				END


				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '11-001'
					AND PreopCC = '11-%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN 00 AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
			END	
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN 00 AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '00' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				END
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '00' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
END



end	
if @xvalor = NULL
set @xvalor = 0
return @xvalor
END

					
		--	BEGIN
		--		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
		--		set @xvalor =
		--		(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = '11-001'
		--			AND PreopCC like '12-001%'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--		end
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '00' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END


			
		--ELSE
		--	BEGIN
		--		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
		--		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		--		set @xvalor = 
		--		(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = @CCosto
		--			AND PreopCC like @CCosto+'%'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--		end
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '01' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END
			

		--END

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		 set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]
									where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta 
									AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
			set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] 
								where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  
								AND bdsession = @bd  and ano = @ano)
			IF(@existeDist = 1)
			BEGIN 
			   if(@nivelcuenta=10)
								begin
									set @xvalor=
										(SELECT sum(preopdebe-preophaber) 
											FROM CIS.softland.cwpreop 
											WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND Preopmes 
											BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%' )
											set @xvalor = ((@xvalor*@porcentaje)/100)
								end
								if(@nivelcuenta=11)
									begin 
				
				 set @xvalor=(SELECT sum(preopdebe-preophaber) 
				 FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-051') AND Preopmes 
				 BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%')
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end

				if(@nivelcuenta=12)
				begin
				set @xvalor=(
				SELECT sum(preopdebe-preophaber) 
				FROM CIS.softland.cwpreop 
				WHERE PreopCta IN ('4-1-05-005') AND Preopmes 
				BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%' )
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end

			    if(@nivelcuenta=13)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-01-009')AND Preopmes
				 BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '11-%')
			    set @xvalor = ((@xvalor*@porcentaje)/100)
				end
	           
			   if(@nivelcuenta=14)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-006'
						,'4-1-05-007'
						,'4-1-05-009'
						,'4-1-05-011'
						,'4-1-05-015'
						,'4-1-05-017'
						,'4-1-05-019'
						,'4-1-05-025'
						,'4-1-05-027'
						,'4-1-05-033'
						,'4-1-05-034'
						,'4-1-05-037'
						,'4-1-05-041'
						,'4-1-05-051'
						,'4-1-05-055'
						,'4-1-05-099'
						)AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND 
						preopano=@ano AND preopcc like '11-%')
										set @xvalor = ((@xvalor*@porcentaje)/100)
							end
							
			   if(@nivelcuenta=15)
					begin
					set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND @mes AND preopano=@ano AND preopcc like '11-%' AND 
						Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND 
						preopano='2019' AND preopcc like '11-%')
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end
				   if(@nivelcuenta=16)
						begin
						set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND
						 preopano=@ano AND preopcc like '11-%')
						set @xvalor = ((@xvalor*@porcentaje)/100)
				end
	END

	else
	BEGIN 						
				if(@nivelcuenta=10)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) 
				FROM CIS.softland.cwpreop 
				WHERE PreopCta IN ('4-1-05-001','4-1-05-002') AND 
				Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2) 
				AND preopano=@ano AND preopcc like @CCosto+'%' )
				end
		    	if(@nivelcuenta=11)
				begin 	
				 set @xvalor=(SELECT sum(preopdebe-preophaber) 
				 FROM CIS.softland.cwpreop 
				 WHERE PreopCta IN ('4-1-05-051') AND Preopmes 
				 BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like @CCosto+'%')
				end
				if(@nivelcuenta=12)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber)
				 FROM CIS.softland.cwpreop 
				 WHERE PreopCta IN ('4-1-05-005') 
				 AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2) 
				 AND preopano=@ano AND preopcc like @CCosto+'%' )
				
				end

			    if(@nivelcuenta=13)
				begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-01-009')AND Preopmes 
				BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)AND preopano=@ano AND preopcc like '@CCosto')
		end
	    if(@nivelcuenta=14)
     	begin
				set @xvalor=(SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN ('4-1-05-006'
						,'4-1-05-007'
						,'4-1-05-009'
						,'4-1-05-011'
						,'4-1-05-015'
						,'4-1-05-017'
						,'4-1-05-019'
						,'4-1-05-025'
						,'4-1-05-027'
						,'4-1-05-033'
						,'4-1-05-034'
						,'4-1-05-037'
						,'4-1-05-041'
						,'4-1-05-051'
						,'4-1-05-055'
						,'4-1-05-099'
						)AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2) 
						AND preopano=@ano AND preopcc like '@CCosto')
				end
			   if(@nivelcuenta=15)
				begin
				set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND @mes AND preopano=@ano AND preopcc like '@CCosto'
						 AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)
						 AND preopano='2019' AND preopcc like '@CCosto')
				end
	  		   if(@nivelcuenta=16)
			begin	
				set @xvalor=(
						SELECT sum(preopdebe-preophaber) FROM CIS.softland.cwpreop WHERE PreopCta IN (
						'4-1-05-028'
						,'4-1-05-029'
						,'4-1-05-030'
						,'4-1-05-032')AND Preopmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@mes,103) ))),2)
						AND preopano=@ano AND preopcc like '@CCosto')
			    
				end
end
end

	
				--set @xvalor =
				--(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = '11-001'
		--			AND PreopCC = '11-001'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--	END	
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '01' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END


		--	END
		--ELSE
		--	BEGIN
		--		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
		--		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		--		set @xvalor = 
		--		(
		--			SELECT 
		--			isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--			FROM  CIS.softland.cwpreop
		--			WHERE PreopAno = @ano
		--			AND Preop_id = @IDPresupuesto
		--			--AND PreopCC = @CCosto
		--			AND PreopCC like @CCosto+'%'
		--			AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--			(
		--				select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--			)
		--			AND PreopMes BETWEEN '00' AND @mes
		--		)

		--		set @xvalor = ((@xvalor * @xvalorDist)/100)
		--		END
		--		IF(@existeSuma > 0)
		--			BEGIN
		--				set @xvalorSuma = 
		--				(
		--					SELECT 
		--					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
		--					FROM  CIS.softland.cwpreop
		--					WHERE PreopAno = @ano
		--					AND Preop_id = @IDPresupuesto
		--					--AND PreopCC = @CCosto
		--					AND PreopCC like @CCosto+'%'
		--					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		--					(
		--						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
		--					)
		--					AND PreopMes BETWEEN '00' AND @mes
		--				)
						
		--				set @xvalor = (@xvalor + @xvalorSuma)

		--			END
--END

	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0')
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta)
				end
				--set @xvalor = '3'
				if(@nivelcuenta=17)
					begin
					set @xvalor = 
						(SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-001','4-1-05-002') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND PreopCC like '01-%' )						
				set @xvalor = ((@xvalor*@porcentaje)/100)
					end
				if(@nivelcuenta=18)
				begin
				set @xvalor = 
						(SELECT sum(preopdebe-preophaber) 
						FROM CIS.softland.cwpreop 
						WHERE preopcta IN
						 ('4-1-05-007',
						 '4-1-05-009',
						 '4-1-05-011',
						 '4-1-05-013',
						 '4-1-05-015',
						 '4-1-05-017',
						 '4-1-05-019',
						 '4-1-05-021',
						 '4-1-05-025',
						 '4-1-05-027',
						 '4-1-05-033',
						 '4-1-05-035',
						 '4-1-05-037',
						 '4-1-05-041',
						 '4-1-05-043',
						 '4-1-05-046',
						 '4-1-05-047',
						 '4-1-05-051',
						 '4-1-05-053',
						 '4-1-05-055',
						 '4-1-05-099',
						 '5-1-01-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103) 
						   AND preopano=@ano AND preopcc like '01-%' )
						   end
	if(@nivelcuenta=26)
				begin
				set @xvalor = 
					   (SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND preopcc like '01-%' )
				set @xvalor = ((@xvalor*@porcentaje)/100)
			end
	else
			if(@nivelcuenta=17)
					begin
					set @xvalor = 
						(SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-001','4-1-05-002') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND PreopCC like @CCosto )
		 		set @xvalor = ((@xvalor*@porcentaje)/100)
				end
				if(@nivelcuenta=18)
				begin
				set @xvalor = 
						(SELECT sum(preopdebe-preophaber) 
						FROM CIS.softland.cwpreop 
						WHERE preopcta IN
						 ('4-1-05-007',
						 '4-1-05-009',
						 '4-1-05-011',
						 '4-1-05-013',
						 '4-1-05-015',
						 '4-1-05-017',
						 '4-1-05-019',
						 '4-1-05-021',
						 '4-1-05-025',
						 '4-1-05-027',
						 '4-1-05-033',
						 '4-1-05-035',
						 '4-1-05-037',
						 '4-1-05-041',
						 '4-1-05-043',
						 '4-1-05-046',
						 '4-1-05-047',
						 '4-1-05-051',
						 '4-1-05-053',
						 '4-1-05-055',
						 '4-1-05-099',
						 '5-1-01-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103) 
						   AND preopano=@ano AND preopcc like @CCosto+'%' )
						   end
				if(@nivelcuenta=26)
					begin
					set @xvalor = 
					   (SELECT sum(preopdebe-preophaber)
						 FROM CIS.softland.cwpreop 
						 WHERE preopcta IN ('4-1-05-003') 
						 AND preopmes BETWEEN '00'
						  AND convert(datetime,@mes,103)
						    AND preopano=@ano AND preopcc like @CCosto+'%' )
					set @xvalor = ((@xvalor*@porcentaje)/100)
	end
end

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @tipocuenta = (select b.PCTIPO from CIS.softland.cwpreop a inner join cis.softland.cwpctas b on a.preopcta = pccodi 
		where a.preop_id =@IDPresupuesto and a.preopAno = @ano and a.preopcc like @CCosto +'%' and a.preopMes = @mes AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd))


		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	IF(@obtengoNivel = 0)
	BEGIN
		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
					set @xvalor = (@xvalor *-1)
					--set @xvalor = '123465798'
	END

END


END  

*/
GO
/****** Object:  UserDefinedFunction [dbo].[returnPPTOForecast]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnPPTOForecast]
(@ano varchar(20),@IDPresupuesto varchar(50),@CCosto varchar(20), @nivelCuenta varchar(20),@bd varchar(30),@mes varchar(6),@condicion int) 
returns float(50)
as
BEGIN
declare @xvalor float(50)
declare @xvalorDist float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float(50)
declare @obtengoNivel int
declare @existeSuma int


set @obtengoNivel = (select idNivel from dscis.dbo.DS_nivelesEERR where idcuenta = @nivelCuenta AND bdsession = @bd)

--select * from dscis.dbo.DS_AgrupacionCuentas where idNivel = '0'
--select * from dscis.dbo.DS_nivelesEERR where idcuenta = '0' and bdsession = 'CIS'

IF(@condicion = 0)
BEGIN
set @existeDist = 
(
	--select * from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '13-001' AND idCuenta =  '5' AND valor <> '100' AND valor <> '0'
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta =  @nivelCuenta AND valor <> '100' AND valor <> '0'  AND bdsession = @bd AND ano = @ano
)
	BEGIN


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 0)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  AND ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  AND ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd AND ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  AND ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  AND ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0'  AND ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '12-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '11-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
--@nivelCuenta

				IF(@nivelCuenta = 21 OR @nivelCuenta = 22 OR @nivelCuenta = 25)
				BEGIN
					set @xvalor = (@xvalor *-1)
				END
				

				IF(@nivelCuenta = 20)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

				IF(@nivelCuenta = 24)
				BEGIN
					IF(@xvalor >0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND ano = @ano )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	


	END

END
ELSE
BEGIN
/*
set @xvalor = 
(
	SELECT 
	isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
	FROM  CIS.softland.cwpreop
	WHERE PreopAno = @ano
	AND Preop_id = @IDPresupuesto
	AND PreopCC = @CCosto
	AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
	)
	AND PreopMes BETWEEN '01' AND @mes
)

set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto and idCuenta = @nivelCuenta)

set @xvalor = ((@xvalor * @porcentaje)/100)
*/

IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0'  AND ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '12-001'
					AND PreopCC like '12%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			--set @xvalor = '123465798'

			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '11-001'
					AND PreopCC like '11%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	IF(@obtengoNivel = 0)
	BEGIN
		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
					set @xvalor = (@xvalor *-1)
					--set @xvalor = '1111111111'
	END

END


if @xvalor = NULL
set @xvalor = 1
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnPPTOForecastCIS]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnPPTOForecastCIS](@ano varchar(20),@IDPresupuesto varchar(50),@CCosto varchar(20), @nivelCuenta varchar(20),@bd varchar(30),@mes varchar(6),@condicion int) 
returns float(50)
as
BEGIN
declare @xvalor float(50)
declare @xvalorDist float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float(50)
declare @obtengoNivel int
declare @existeSuma int


set @obtengoNivel = (select idNivel from dscis.dbo.DS_nivelesEERR where idcuenta = @nivelCuenta)

--select * from dscis.dbo.DS_AgrupacionCuentas where idNivel = '5'
--select * from dscis.dbo.DS_nivelesEERR where idcuenta = '5'

IF(@condicion = 0)
BEGIN
set @existeDist = 
(
	--select * from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '13-001' AND idCuenta =  '5' AND valor <> '100' AND valor <> '0'
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta =  @nivelCuenta AND valor <> '100' AND valor <> '0' AND BDSession = @bd
)
	BEGIN


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 0)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0'  AND BDSession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND BDSession = @bd )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND BDSession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND BDSession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND BDSession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '12-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idnivel = @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes =  @mes and ccnivel.idnivel = @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND BDSession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND BDSession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND BDSession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '11-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idnivel = @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes =  @mes and ccnivel.idnivel = @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND BDSession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
--@nivelCuenta

				IF(@nivelCuenta = 21 OR @nivelCuenta = 22 OR @nivelCuenta = 25)
				BEGIN
					set @xvalor = (@xvalor *-1)
				END
				

				IF(@nivelCuenta = 20)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

				IF(@nivelCuenta = 24)
				BEGIN
					IF(@xvalor >0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND BDSession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND BDSession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idnivel = @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes =  @mes and ccnivel.idnivel = @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND BDSession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND BDSession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND BDSession = @bd )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idnivel = @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes =  @mes and ccnivel.idnivel = @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND BDSession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND BDSession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND BDSession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idnivel = @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes =  @mes and ccnivel.idnivel = @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND BDSession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	


	END

END
ELSE
BEGIN
/*
set @xvalor = 
(
	SELECT 
	isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
	FROM  CIS.softland.cwpreop
	WHERE PreopAno = @ano
	AND Preop_id = @IDPresupuesto
	AND PreopCC = @CCosto
	AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
	)
	AND PreopMes BETWEEN '01' AND @mes
)

set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto and idCuenta = @nivelCuenta)

set @xvalor = ((@xvalor * @porcentaje)/100)
*/

IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND BDSession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND BDSession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '12-001'
					AND PreopCC like '12%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id =@IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12' and ccnivel.idnivel=@obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			--set @xvalor = '123465798'

			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND BDSession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'

					
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND BDSession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND BDSession = @bd )
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '11-001'
					AND PreopCC like '11%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id =@IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12' and ccnivel.idnivel = @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'

						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND BDSession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND BDSession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND BDSession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id =@IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12' and ccnivel.idnivel = @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND BDSession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND BDSession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND BDSession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id =@IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12' and ccnivel.idnivel = @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND BDSession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND BDSession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND BDSession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id =@IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12' and ccnivel.idnivel = @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND BDSession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	IF(@obtengoNivel = 0)
	BEGIN
		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND BDSession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND BDSession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN @mes AND '12'
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN @mes AND '12'
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
					set @xvalor = (@xvalor *-1)
					--set @xvalor = '123465798'
	END

END


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnPPTOHORNILLAS]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnPPTOHORNILLAS](@ano varchar(20),@IDPresupuesto varchar(50),@CCosto varchar(20), @nivelCuenta varchar(20),@bd varchar(30),@mes varchar(6),@condicion int) 
returns float(50)
as
BEGIN
declare @xvalor float(50)
declare @xvalorDist float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float(50)
declare @obtengoNivel int
declare @existeSuma int


set @obtengoNivel = (select idNivel from dscis.dbo.DS_nivelesEERR where idcuenta = @nivelCuenta AND bdsession = @bd)

--select * from dscis.dbo.DS_AgrupacionCuentas where idNivel = '5'
--select * from dscis.dbo.DS_nivelesEERR where idcuenta = '5'

IF(@condicion = 0)
BEGIN
set @existeDist = 
(
	--select * from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '13-001' AND idCuenta =  '5' AND valor <> '100' AND valor <> '0'
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta =  @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd
)
	BEGIN


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 0)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '12-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					wHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel= @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '11-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					wHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel= @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
--@nivelCuenta

				IF(@nivelCuenta = 21 OR @nivelCuenta = 22 OR @nivelCuenta = 25)
				BEGIN
					set @xvalor = (@xvalor *-1)
				END
				

				IF(@nivelCuenta = 20)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

				IF(@nivelCuenta = 24)
				BEGIN
					IF(@xvalor >0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					wHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel= @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					wHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel= @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					wHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel= @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	


	END

END
ELSE
BEGIN
/*
set @xvalor = 
(
	SELECT 
	isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
	FROM  CIS.softland.cwpreop
	WHERE PreopAno = @ano
	AND Preop_id = @IDPresupuesto
	AND PreopCC = @CCosto
	AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
	)
	AND PreopMes BETWEEN '01' AND @mes
)

set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto and idCuenta = @nivelCuenta)

set @xvalor = ((@xvalor * @porcentaje)/100)
*/

IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '12-001'
					AND PreopCC like '12%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel= @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			--set @xvalor = '123465798'

			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '11-001'
					AND PreopCC like '11%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel= @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel= @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel= @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(preop.PreopCC,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel= @obtengoNivel
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	IF(@obtengoNivel = 0)
	BEGIN
		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta AND bdsession = @bd)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto+'-000' and idCuenta = @nivelCuenta  AND bdsession = @bd)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  CIS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
					set @xvalor = (@xvalor *-1)
					--set @xvalor = '123465798'
	END

END


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnPPTONUEVAHORNILLAS]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnPPTONUEVAHORNILLAS](@ano varchar(20),@IDPresupuesto varchar(50),@CCosto varchar(20), @nivelCuenta varchar(20),@bd varchar(30),@mes varchar(6),@condicion int) 
returns float(50)
as
BEGIN
declare @xvalor float(50)
declare @xvalorDist float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float(50)
declare @obtengoNivel int
declare @existeSuma int


set @obtengoNivel = (select idNivel from dscis.dbo.DS_nivelesEERR where idcuenta = @nivelCuenta AND bdsession = @bd)

--select * from dscis.dbo.DS_AgrupacionCuentas where idNivel = '5'
--select * from dscis.dbo.DS_nivelesEERR where idcuenta = '5'

IF(@condicion = 0)
BEGIN
set @existeDist = 
(
	--select * from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '13-001' AND idCuenta =  '5' AND valor <> '100' AND valor <> '0'
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta =  @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano
)
	BEGIN


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 0)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '12-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '11-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
--@nivelCuenta

				IF(@nivelCuenta = 21 OR @nivelCuenta = 22 OR @nivelCuenta = 25)
				BEGIN
					set @xvalor = (@xvalor *-1)
				END
				

				IF(@nivelCuenta = 20)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

				IF(@nivelCuenta = 24)
				BEGIN
					IF(@xvalor >0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano )
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	


	END

END
ELSE
BEGIN
/*
set @xvalor = 
(
	SELECT 
	isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
	FROM  NUEVAHORNILLAS.softland.cwpreop
	WHERE PreopAno = @ano
	AND Preop_id = @IDPresupuesto
	AND PreopCC = @CCosto
	AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
	)
	AND PreopMes BETWEEN '01' AND @mes
)

set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto and idCuenta = @nivelCuenta)

set @xvalor = ((@xvalor * @porcentaje)/100)
*/

IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '12-001'
					AND PreopCC like '12%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							--AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			--set @xvalor = '123465798'

			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					--AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							--AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '11-001'
					AND PreopCC like '11%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							--AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					--AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							--AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							--AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					--AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							--AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							--AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					--AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							--AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							--AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					--AND PreopCC like @CCosto+'%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							--AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	IF(@obtengoNivel = 0)
	BEGIN
		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					--AND PreopCC like @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							--AND PreopCC like @CCosto+'%'
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
					set @xvalor = (@xvalor *-1)
					--set @xvalor = '123465798'
	END

END


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnPPTONUEVAHORNILLAS2]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnPPTONUEVAHORNILLAS2](@ano varchar(20),@IDPresupuesto varchar(50),@CCosto varchar(20), @nivelCuenta varchar(20),@bd varchar(30),@mes varchar(6),@condicion int) 
returns float(50)
as
BEGIN
declare @xvalor float(50)
declare @xvalorDist float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float(50)
declare @obtengoNivel int
declare @existeSuma int
Declare @tipocuenta varchar(50)


set @obtengoNivel = (select idNivel from dscis.dbo.DS_nivelesEERR where idcuenta = @nivelCuenta AND bdsession = @bd)

--select * from dscis.dbo.DS_AgrupacionCuentas where idNivel = '5'
--select * from dscis.dbo.DS_nivelesEERR where idcuenta = '5'

IF(@condicion = 0)
BEGIN
set @existeDist = 
(
	--select * from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '13-001' AND idCuenta =  '5' AND valor <> '100' AND valor <> '0'
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta =  @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano
)
	BEGIN


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 0)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  CIS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '12-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '11-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
--@nivelCuenta

				IF(@nivelCuenta = 21 OR @nivelCuenta = 22 OR @nivelCuenta = 25)
				BEGIN
					set @xvalor = (@xvalor *-1)
				END
				

				IF(@nivelCuenta = 20)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

				IF(@nivelCuenta = 24)
				BEGIN
					IF(@xvalor >0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano )
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
						)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		
		set @tipocuenta = (select b.PCTIPO from NUEVAHORNILLAS.softland.cwpreop a inner join NUEVAHORNILLAS.softland.cwpctas b on a.preopcta = pccodi 
		where a.preop_id =@IDPresupuesto and a.preopAno = @ano and a.preopcc = @CCosto and a.preopMes = @mes AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd))

		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = '01-001'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes*/

					SELECT 
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes and ccnivel.idnivel=@obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes = @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes = @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	


	END

END
ELSE
BEGIN
/*
set @xvalor = 
(
	SELECT 
	isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
	FROM  NUEVAHORNILLAS.softland.cwpreop
	WHERE PreopAno = @ano
	AND Preop_id = @IDPresupuesto
	AND PreopCC = @CCosto
	AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
	)
	AND PreopMes BETWEEN '01' AND @mes
)

set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto and idCuenta = @nivelCuenta)

set @xvalor = ((@xvalor * @porcentaje)/100)
*/

IF(@obtengoNivel = 1)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '12-001'
					AND PreopCC like '12%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			--set @xvalor = '123465798'

			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 2)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '11-001'
					AND PreopCC like '11%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 3)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL


--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 4)
	BEGIN
		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL

	--INICIO BLOQUE POR NIVEL
IF(@obtengoNivel = 5)
	BEGIN
		set @tipocuenta = (select b.PCTIPO from NUEVAHORNILLAS.softland.cwpreop a inner join NUEVAHORNILLAS.softland.cwpctas b on a.preopcta = pccodi 
		where a.preop_id =@IDPresupuesto and a.preopAno = @ano and a.preopcc = @CCosto and a.preopMes = @mes AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
		(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd))


		set @existeDist = (select count(*) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND valor <> '100' AND valor <> '0' AND bdsession = @bd  and ano = @ano)
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
		IF(@existeDist = 1)
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @xvalor =
				(
					/*SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = '01-001'
					AND PreopCC like '01%'
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes*/

					SELECT
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop preop
					INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON preop.PreopCC collate Modern_Spanish_CI_AS = ccnivel.codiCC
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes and ccnivel.idnivel = @obtengoNivel AND ccnivel.BDSession = @bd
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)
				
				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END


			END
		ELSE
			BEGIN
				set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					(
						CASE 
						WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
							THEN  isnull(sum(PreopDebe-PreopHaber),0)
						WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
							THEN  isnull(sum(PreopHaber-PreopDebe),0)
						WHEN   @tipocuenta is null
							THEN  0
						END 		 
					) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							(
								CASE 
								WHEN  @tipocuenta = 'A' or @tipocuenta = 'C' or @tipocuenta = 'G' or @tipocuenta = 'T' 
									THEN  isnull(sum(PreopDebe-PreopHaber),0)
								WHEN   @tipocuenta = 'I' or @tipocuenta = 'P'
									THEN  isnull(sum(PreopHaber-PreopDebe),0)
								WHEN   @tipocuenta is null
									THEN  0
								END 		 
							) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
			END
	END
	--TERMINO BLOQUE POR NIVEL
	IF(@obtengoNivel = 0)
	BEGIN
		set @xvalorDist = (select valor from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta AND bdsession = @bd  and ano = @ano)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC]  where CodiCC = @CCosto and idCuenta = @nivelCuenta  AND bdsession = @bd  and ano = @ano)
				set @xvalor = 
				(
					SELECT 
					isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
					FROM  NUEVAHORNILLAS.softland.cwpreop
					WHERE PreopAno = @ano
					AND Preop_id = @IDPresupuesto
					--AND PreopCC = @CCosto
					AND PreopCC = @CCosto
					AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
					(
						select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
					)
					AND PreopMes BETWEEN '01' AND @mes
				)

				set @xvalor = ((@xvalor * @xvalorDist)/100)

				IF(@existeSuma > 0)
					BEGIN
						set @xvalorSuma = 
						(
							SELECT 
							isnull(sum(PreopDebe-PreopHaber),0) as resultadoSuma
							FROM  NUEVAHORNILLAS.softland.cwpreop
							WHERE PreopAno = @ano
							AND Preop_id = @IDPresupuesto
							--AND PreopCC = @CCosto
							AND PreopCC = @CCosto
							AND PreopCta COLLATE Modern_Spanish_CI_AS IN 
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] WHERE idNivel =  @nivelCuenta AND BDSession = @bd
							)
							AND PreopMes BETWEEN '01' AND @mes
						)
						
						set @xvalor = (@xvalor + @xvalorSuma)

					END
					set @xvalor = (@xvalor *-1)
					--set @xvalor = '123465798'
	END

END


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnREAL]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnREAL](@ano varchar(20),@nivel varchar(10),@fechaDesde varchar(15), @fechaHasta varchar(15),@CCosto varchar(15),@bd varchar(10),@nivelEERR int)
returns int
as
BEGIN
declare @xvalor float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float
declare @existeSuma int
declare @primerNivel int
set @existeDist = 
(
	--select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta =  @nivel AND valor <> '100' AND valor <> '0' AND ano = @ano
)
IF(@existeDist > 0)
	BEGIN
		--set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel)
		--select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '20-001' AND idCuenta = '4'
		--set @xvalor = ((@xvalor*@porcentaje)/100)	
		IF(@nivelEERR = 1)
			BEGIN
				--set @xvalor = '1'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND movim.ccCod like '12%' AND cpbte.CpbEst = 'V'
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
				--set @xvalor = (@xvalor *-1)
			END
		IF(@nivelEERR = 2)
			BEGIN
				--set @xvalor = '2'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							
							AND movim.ccCod like '11%' AND cpbte.CpbEst = 'V'
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 3)
			BEGIN
				--set @xvalor = '3'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							--AND movim.ccCod = '01-001' AND cpbte.CpbEst = 'V' 
							AND movim.ccCod like '01%' AND cpbte.CpbEst = 'V' 
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 4)
			BEGIN
				--set @xvalor = '4'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							--AND movim.ccCod = '01-001' AND cpbte.CpbEst = 'V'
							AND movim.ccCod like '01%' AND cpbte.CpbEst = 'V'
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno =@ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 5)
			BEGIN
				--set @xvalor = '5'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
							WHERE movim.cpbano = @ano and cpbte.CpbAno =@ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							--AND movim.ccCod = '01-001' AND cpbte.CpbEst = 'V'
							AND movim.ccCod like '01%' AND cpbte.CpbEst = 'V'
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END

				IF(@nivel = 21 OR @nivel = 22 OR @nivel = 25)
				BEGIN
					set @xvalor = (@xvalor *-1)
				END
				

				IF(@nivel = 20)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

				IF(@nivel = 24)
				BEGIN
					IF(@xvalor >0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

			END
	END
ELSE
	BEGIN
		--set @xvalor = '99999999999999'
		--select idNivel from [DSCIS].[dbo].[DS_DistribucionCC]
		
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
		set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
		set @xvalor = 
					(
						SELECT 
						isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
						FROM CIS.softland.cwmovim movim 
						INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
						INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
						WHERE movim.cpbano = @ano and cpbte.CpbAno =@ano
						AND movim.pctcod collate Modern_Spanish_CI_AS IN   
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
						) 
						and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
						--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
						AND movim.ccCod like ''+@CCosto+'%' AND cpbte.CpbEst = 'V'
					)
		set @xvalor = ((@xvalor*@porcentaje)/100)
		--set @xvalor = '777777'

	IF(@existeSuma > 0)
	BEGIN
		set @xvalorSuma = 
					(
						SELECT 
						isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
						FROM CIS.softland.cwmovim movim 
						INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
						INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
						WHERE movim.cpbano = @ano and cpbte.CpbAno =@ano
						AND movim.pctcod collate Modern_Spanish_CI_AS IN   
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
						) 
						and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
						--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V' 
						AND movim.ccCod like ''+@CCosto+'%' AND cpbte.CpbEst = 'V'

					)

		set @xvalor = (@xvalor + @xvalorSuma)
	END

	set @primerNivel = (select idNivel from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)

		IF(@primerNivel = 0)
		BEGIN
			set @xvalor = (@xvalor *-1)
		END
	END

--select 13056852*10/100,13056852
--set @xvalor = (@xvalor)
if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnRealAcumulado]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnRealAcumulado](@ano varchar(8),@nivel varchar(4),@bd varchar(5), @fechaDesdeAcumulado varchar(20),@fechaHastaAcumulado varchar(20),@CCosto varchar(20)  )
--returns float(25)
returns int
as
BEGIN
declare @xvalor float(25)

set @xvalor = 
(
	select 
	isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
	from CIS.softland.cwmovim movim 
	INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
	INNER JOIN CIS.softland.cwcpbte cpbte ON movim.CpbNum = cpbte.CpbNum
	where movim.cpbano = @ano and cpbte.CpbAno = @ano
	AND movim.pctcod collate Modern_Spanish_CI_AS IN   
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
	) 
	and movim.CpbFec  BETWEEN convert(datetime,@fechaDesdeAcumulado,103) AND convert(datetime,@fechaHastaAcumulado,103) 
	AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
)


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnRealAcumuladoCIS]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnRealAcumuladoCIS](@ano varchar(8),@nivel varchar(4),@bd varchar(50), @fechaDesdeAcumulado varchar(20),@fechaHastaAcumulado varchar(20),@CCosto varchar(20)  )
--returns float(25)
returns int
as
BEGIN
declare @xvalor float(25)

set @xvalor = 
(
	select 
	isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
	from CIS.softland.cwmovim movim 
	INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
	INNER JOIN CIS.softland.cwcpbte cpbte ON movim.CpbNum = cpbte.CpbNum
	where movim.cpbano = @ano and cpbte.CpbAno = @ano
	AND movim.pctcod collate Modern_Spanish_CI_AS IN   
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
	) 
	and movim.CpbFec  BETWEEN convert(datetime,@fechaDesdeAcumulado,103) AND convert(datetime,@fechaHastaAcumulado,103) 
	AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
)


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnRealAcumuladoHORNILLAS]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create function [dbo].[returnRealAcumuladoHORNILLAS](@ano varchar(8),@nivel varchar(4),@bd varchar(50), @fechaDesdeAcumulado varchar(20),@fechaHastaAcumulado varchar(20),@CCosto varchar(20)  )
--returns float(25)
returns int
as
BEGIN
declare @xvalor float(25)

set @xvalor = 
(
	select 
	isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
	from CIS.softland.cwmovim movim 
	INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
	INNER JOIN CIS.softland.cwcpbte cpbte ON movim.CpbNum = cpbte.CpbNum
	where movim.cpbano = @ano
	AND movim.pctcod collate Modern_Spanish_CI_AS IN   
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
	) 
	and movim.CpbFec  BETWEEN convert(datetime,@fechaDesdeAcumulado,103) AND convert(datetime,@fechaHastaAcumulado,103) 
	AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
)


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnRealAcumuladoNUEVAHORNILLAS]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnRealAcumuladoNUEVAHORNILLAS](@ano varchar(8),@nivel varchar(4),@bd varchar(50), @fechaDesdeAcumulado varchar(20),@fechaHastaAcumulado varchar(20),@CCosto varchar(20)  )
--returns float(25)
returns int
as
BEGIN
declare @xvalor float(25)

set @xvalor = 
(
	select 
	isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
	from NUEVAHORNILLAS.softland.cwmovim movim 
	INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
	INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.CpbNum = cpbte.CpbNum
	where movim.cpbano = @ano
	AND movim.pctcod collate Modern_Spanish_CI_AS IN   
	(
		select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
	) 
	and movim.CpbFec  BETWEEN convert(datetime,@fechaDesdeAcumulado,103) AND convert(datetime,@fechaHastaAcumulado,103) 
	AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
)


if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnREALCIS]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnREALCIS]
(@ano varchar(20),
@nivel varchar(10),
@fechaDesde varchar(15), 
@fechaHasta varchar(15),
@CCosto varchar(15),
@bd varchar(20),
@nivelEERR int)
returns decimal
as
BEGIN
declare @xvalor decimal(20,1)
declare @xvalorSuma int
declare @existeDist int
declare @porcentaje float
declare @existeSuma int
declare @primerNivel int
declare @limpia int
declare @centrocostodist varchar(50)
declare @xvalorLaboratorio float
declare @xvalorLaboratoriob float
declare @porcentajeLAB float
declare @porcentajeLABb float

set @existeDist = (select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' 
AND idCuenta =  @nivel AND valor <> '100' AND valor <> '0' AND BDSession = @bd and ano = @ano)

IF(@existeDist > 0)
	BEGIN
		set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel)
		set @xvalor = ((@xvalor*@porcentaje)/100)	
		IF(@nivelEERR = 1)
			BEGIN
			set @xvalor = 0
			set @xvalorLaboratorio = 0
			set @xvalorLaboratoriob = 0
			set @porcentaje = 0
			set @porcentajeLAB = 0
			set @porcentajeLABb = 0
			
			set @xvalorLaboratorio = (SELECT isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
			FROM CIS.softland.cwmovim movim 
			INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
			INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum  
			WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano AND movim.pctcod collate Modern_Spanish_CI_AS IN   
			(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = 27 AND BDSession = 'CIS') 
			and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103)  
			AND cpbte.CpbEst = 'V' and SUBSTRING(movim.CcCod,1,2) collate Modern_Spanish_CI_AS = '22')
			set @xvalorLaboratorio = ((@xvalorLaboratorio * 100)/1000)
			set @xvalorLaboratorio = (@xvalorLaboratorio / 2)

			set @xvalorLaboratoriob = (SELECT isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
			FROM CIS.softland.cwmovim movim 
			INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
			INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
			WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano AND movim.pctcod collate Modern_Spanish_CI_AS IN   
			(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = 28 AND BDSession = 'CIS') 
			and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
			AND cpbte.CpbEst = 'V'and SUBSTRING(movim.CcCod,1,2) collate Modern_Spanish_CI_AS = '22')
			set @xvalorLaboratoriob = ((@xvalorLaboratoriob * 100)/1000)
			set @xvalorLaboratoriob = (@xvalorLaboratoriob / 2)



			set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd  and ano = @ano)
			set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
			set @xvalor = (SELECT isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum  
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel --and idnivel not in (28) 
							AND BDSession =@bd) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd
							and SUBSTRING(movim.CcCod,1,2) collate Modern_Spanish_CI_AS in (select SUBSTRING(codicc,1,2) from DSCIS.DBO.ccdistribuible where idnivel=@nivelEERR))
							if @nivel = 27 and @CCosto+'-000' = '13-000'
							begin
							set @porcentajeLAB = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratorio*@porcentajeLAB)/10)
							end
							else
							if @nivel = 27 and @CCosto+'-000' = '08-000'
							begin
							set @porcentajeLAB = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratorio*@porcentajeLAB)/10)
							end
							else
							if @nivel = 27 and @CCosto+'-000' = '14-000'
							begin
							set @porcentajeLAB = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratorio*@porcentajeLAB)/10)
							end
							else
							if @nivel = 27 and @CCosto+'-000' = '15-000'
							begin
							set @porcentajeLAB = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratorio*@porcentajeLAB)/10)
							end
							else
							if @nivel = 27 and @CCosto+'-000' = '16-000'
							begin
							set @porcentajeLAB = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratorio*@porcentajeLAB)/10)
							end
							else
							if @nivel = 27 and @CCosto+'-000' = '18-000'
							begin
							set @porcentajeLAB = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratorio*@porcentajeLAB)/10)
							end
							else
							if @nivel = 27 and @CCosto+'-000' = '19-000'
							begin
							set @porcentajeLAB = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratorio*@porcentajeLAB)/10)
							end
							else
							if @nivel = 28 and @CCosto+'-000' = '13-000'
							begin
							set @porcentajeLABb = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratoriob * @porcentajeLABb)/10)
							end
							else
							if @nivel = 28 and @CCosto+'-000' = '08-000'
							begin
							set @porcentajeLABb = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratoriob * @porcentajeLABb)/10)
							end
							else
							if @nivel = 28 and @CCosto+'-000' = '14-000'
							begin
							set @porcentajeLABb = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratoriob * @porcentajeLABb)/10)
							end
							else
							if @nivel = 28 and @CCosto+'-000' = '15-000'
							begin
							set @porcentajeLABb = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratoriob * @porcentajeLABb)/10)
							end
							else
							if @nivel = 28 and @CCosto+'-000' = '16-000'
							begin
							set @porcentajeLABb = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratoriob * @porcentajeLABb)/10)
							end
							else
							if @nivel = 28 and @CCosto+'-000' = '18-000'
							begin
							set @porcentajeLABb = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratoriob * @porcentajeLABb)/10)
							end
							else
							if @nivel = 28 and @CCosto+'-000' = '19-000'
							begin
							set @porcentajeLABb = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							set @xvalor = ((@xvalorLaboratoriob * @porcentajeLABb)/10)
							end
							else
							set @xvalor = ((@xvalor*@porcentaje)/100)

							--if @nivel = 28 and @CCosto+'-000' = '13-000'
							--begin
							--set @porcentajeLABb = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000'  AND idCuenta = @nivel)
							--set @xvalor = ((@xvalorLaboratoriob*@porcentajeLABb)/10)
							--end
							
							
							--set @xvalor = ((@xvalor*@porcentaje)/100)
							--set @xvalor = (@xvalor + @xvalorLaboratorio)
							--end
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)

							--if @nivel = 28
							--set @xvalor = (@xvalorLaboratoriob * @porcentaje) / 100
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)

							--if @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio / 2))*@porcentaje)/100)
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)
							
							--if @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob / 2))*@porcentaje)/100)
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)
														
							
							--if @CCosto+'-000' = '08-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2)) * @porcentaje)/100) 
							--else
							--if @CCosto+'-000' = '13-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2)) * @porcentaje)/100) 
							--else
							--if @CCosto+'-000' = '14-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)	
							
							--if @CCosto+'-000' = '08-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)
							
							--if @CCosto+'-000' = '14-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)
							
							--if @CCosto+'-000' = '15-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)
							
							--if @CCosto+'-000' = '16-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)

							--if @CCosto+'-000' = '18-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)

							--if @CCosto+'-000' = '19-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)
											
							--if @CCosto+'-000' = '08-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2)) * @porcentaje)/100) 
							--else
							--if @CCosto+'-000' = '13-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2)) * @porcentaje)/100) 
							--else
							--if @CCosto+'-000' = '14-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)	
							
							--if @CCosto+'-000' = '08-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)	

							--if @CCosto+'-000' = '14-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)	

							--if @CCosto+'-000' = '15-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)	

							--if @CCosto+'-000' = '16-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)	

							--if @CCosto+'-000' = '18-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)	

							--if @CCosto+'-000' = '19-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2)) * @porcentaje)/100) 
							--else
							--set @xvalor = ((@xvalor*@porcentaje)/100)	
							
				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = (SELECT isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN (select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									AND movim.ccCod like @CCosto+'-%' AND cpbte.CpbEst = 'V')

							--if @CCosto+'-000' = '08-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--if @CCosto+'-000' = '13-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--if @CCosto+'-000' = '14-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)	

							--if @CCosto+'-000' = '08-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)

							--if @CCosto+'-000' = '14-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)

							--if @CCosto+'-000' = '15-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)

							--if @CCosto+'-000' = '16-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)

							--if @CCosto+'-000' = '18-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)

							--if @CCosto+'-000' = '19-000' and @nivel = 27
							--set @xvalor = (((@xvalor + (@xvalorLaboratorio/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)

							--if @CCosto+'-000' = '08-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--if @CCosto+'-000' = '13-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--if @CCosto+'-000' = '14-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)	

							--if @CCosto+'-000' = '08-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)

							--if @CCosto+'-000' = '14-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)

							--if @CCosto+'-000' = '15-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)

							--if @CCosto+'-000' = '16-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)

							--if @CCosto+'-000' = '18-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)

							--if @CCosto+'-000' = '19-000' and @nivel = 28
							--set @xvalor = (((@xvalor + (@xvalorLaboratoriob/2) + @xvalorSuma) * @porcentaje)/100) 
							--else
							--set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		
		IF(@nivelEERR = 2)
			BEGIN
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = (SELECT isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd
							and SUBSTRING(movim.CcCod,1,2) collate Modern_Spanish_CI_AS in (select SUBSTRING(codicc,1,2) from DSCIS.DBO.ccdistribuible where idnivel=@nivelEERR ))

				set @xvalor = ((@xvalor*@porcentaje)/100)
				set @limpia=@xvalor
				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(SELECT isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V')
					set @xvalor = (@limpia + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 3)
			BEGIN
				--set @xvalor = '3'
			set @centrocostodist=(select codicc from DSCIS.DBO.ccdistribuible where idnivel=@nivelEERR and codicc= @CCosto)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = (SELECT isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd
							and SUBSTRING(movim.CcCod,1,2) collate Modern_Spanish_CI_AS in (select SUBSTRING(codicc,1,2) from DSCIS.DBO.ccdistribuible where idnivel=@nivelEERR ))
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 4)
			BEGIN
				--set @xvalor = '4'
			set @centrocostodist=(select codicc from DSCIS.DBO.ccdistribuible where idnivel=@nivelEERR and codicc= @CCosto)
			
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							/*SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							--AND movim.ccCod = '01-001' AND cpbte.CpbEst = 'V'
							AND movim.ccCod like '01%' AND cpbte.CpbEst = 'V'*/

							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd

						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 5)
			BEGIN
				--set @xvalor = '5'
					if(@nivel=21)
				begin 
			
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
						)
				set @xvalor =(@xvalor*@porcentaje)/100
	


				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				end
				end
			else
				if(@nivel=24)
				begin 
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
						)
				set @xvalor =(@xvalor*@porcentaje)/100



				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				end
				end
			else
				begin 
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)



				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
				end
			





				
				----IF(@nivel = 21 OR @nivel = 22 OR @nivel = 25)
				--BEGIN
				--	set @xvalor = (@xvalor *-1)
				--END
				

				IF(  @nivel = 22 OR @nivel = 25 or @nivel = 24)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
				
					END
				END

			

				IF(@nivel = 25)
				BEGIN
					declare @xvalorDebe float
					declare @xvalorHaber float


					set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
					set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
					/*
					set @xvalor = 
							(
								SELECT 
								isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
								FROM CIS.softland.cwmovim movim 
								INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
								WHERE movim.cpbano = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
									select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR
							)
					*/
					set @xvalorDebe = 
							(
								SELECT 
								isnull(sum(MovDebe),0) as resultadoSuma
								FROM CIS.softland.cwmovim movim 
								INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
								WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
												select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
							)

					
					set @xvalorHaber = 
							(
								SELECT 
								isnull(sum(MovHaber),0) as resultadoSuma
								FROM CIS.softland.cwmovim movim 
								INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
								WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
												select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
							)
					
					
					--set @xvalor = ((@xvalor*@porcentaje)/100)
					
					declare @sumaDiferencia float
					set @sumaDiferencia = (@xvalorHaber-@xvalorDebe)
					set @xvalor = ((@sumaDiferencia)*@porcentaje/100)
					--set @xvalor = '123456'



					
					
					IF(@existeSuma > 0)
					BEGIN
						declare @xvalorDebeSuma float
						declare @xvalorHaberSuma float
						set @xvalorDebeSuma = 
									(
										SELECT 
										isnull(sum(MovDebe),0) as resultadoSuma
										FROM CIS.softland.cwmovim movim 
										INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
										INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
										WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
										AND movim.pctcod collate Modern_Spanish_CI_AS IN   
										(
														select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
										) 
										and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
										--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
										AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
									)
						set @xvalorHaberSuma = 
									(
										SELECT 
										isnull(sum(MovHaber),0) as resultadoSuma
										FROM CIS.softland.cwmovim movim 
										INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
										INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
										WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
										AND movim.pctcod collate Modern_Spanish_CI_AS IN   
										(
														select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
										) 
										and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
										--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
										AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
									)
					declare @sumaDiferenciaSuma float
					set @sumaDiferenciaSuma = (@xvalorHaberSuma-@xvalorDebeSuma)

						set @xvalor = (@xvalor + @sumaDiferenciaSuma)
						
						--set @xvalor = '999999999'
					END
					




				END


				--set @xvalor = '999999999'
			END
	END
ELSE
	BEGIN
		--set @xvalor = '99999999999999'
		--select idNivel from [DSCIS].[dbo].[DS_DistribucionCC]
		
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
		set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
		set @xvalor = 
					(
						SELECT 
						isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
						FROM CIS.softland.cwmovim movim 
						INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
						INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
						WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
						AND movim.pctcod collate Modern_Spanish_CI_AS IN   
						(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
						) 
						and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
						--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
						AND movim.ccCod like ''+@CCosto+'%' AND cpbte.CpbEst = 'V'

						

					)
		set @xvalor = ((@xvalor*@porcentaje)/100)
		--set @xvalor = '777777'

	IF(@existeSuma > 0)
	BEGIN
		set @xvalorSuma = 
					(
						SELECT 
						isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
						FROM CIS.softland.cwmovim movim 
						INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
						INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
						WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
						AND movim.pctcod collate Modern_Spanish_CI_AS IN   
						(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
						) 
						and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
						--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V' 
						AND movim.ccCod like ''+@CCosto+'%' AND cpbte.CpbEst = 'V'

					)

		set @xvalor = (@xvalor + @xvalorSuma)
	END

	set @primerNivel = (select idNivel from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd  and ano = @ano)

		IF(@primerNivel = 0)
		BEGIN
			set @xvalor = (@xvalor *-1)
		END

		IF(@nivel = 25 or @nivel = 22)
		BEGIN
			set @xvalor = (@xvalor *-1)
		END

END

--select 13056852*10/100,13056852
--set @xvalor = (@xvalor)
if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnREALCIS_123456]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[returnREALCIS_123456](
@ano varchar(20),
@nivel varchar(10),
@fechaDesde varchar(15), 
@fechaHasta varchar(15),
@CCosto varchar(15),
@bd varchar(20),
@nivelEERR int)
returns int
as
BEGIN
declare @xvalor float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float
declare @existeSuma int
declare @primerNivel int
set @existeDist = 
(
	--select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] 
	where codiCC = @CCosto+'-000' 
	AND idCuenta =  @nivel 
	AND valor <> '100' AND valor <> '0' 
	AND BDSession = @bd 
	and ano = @ano
)

		set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC LIKE @CCosto+'-%' AND idCuenta = @nivel)
		--select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '20-001' AND idCuenta = '4'
		--set @xvalor = ((@xvalor*@porcentaje)/100)	
			IF(@existeDist=0)
			BEGIN 
			SET @xvalor=(SELECT sum(movdebe-movhaber) 
						FROM CIS.softland.cwmovim movim
					WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
						AND movim.cpbmes BETWEEN RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechadesde,103) ))),2) 
						AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2) 
						AND cpbano=@ano AND CCCod  like @CCosto+'%' )
			END
		IF(@nivelEERR = 1)
		IF(@existeDist>0)
		BEGIN
	
				--set @xvalor = '1'
						if(@nivel=1)
					begin
						set @xvalor = 
						(SELECT sum(movdebe-movhaber) 
								FROM CIS.softland.cwmovim  movim join cis.softland.cwcpbte b on movim.CpbNum=b.CpbNum  
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
								and b.CpbEst='V'
							AND  movim.cpbmes BETWEEN 00
						AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2) 
								AND movim.cpbano= '2019'
								AND movim.CCCod like '12-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)							
				 end
					
					if(@nivel=2)
					begin 
						set @xvalor = 
						(SELECT sum(movdebe-movhaber) 
								FROM CIS.softland.cwmovim  movim join cis.softland.cwcpbte b on movim.CpbNum=b.CpbNum  
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
								and b.CpbEst='V'
							AND  movim.cpbmes BETWEEN 00
						AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2) 
								AND movim.cpbano= '2019'
								AND movim.CCCod like '12-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)
							end
					if(@nivel=3)
					begin 
						set @xvalor =
						(SELECT sum(movdebe-movhaber) 
								FROM CIS.softland.cwmovim  movim join cis.softland.cwcpbte b on movim.CpbNum=b.CpbNum  
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
								and b.CpbEst='V'
							AND  movim.cpbmes BETWEEN 00
						AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2) 
								AND movim.cpbano= '2019'
								AND movim.CCCod like '12-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)
						set @xvalor=((@xvalor*@porcentaje)/100)
					end


					if(@nivel=4)
					begin 
						set @xvalor = 
							(SELECT sum(movdebe-movhaber) 
								FROM CIS.softland.cwmovim  movim join cis.softland.cwcpbte b on movim.CpbNum=b.CpbNum  
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
								and b.CpbEst='V'
							AND  movim.cpbmes BETWEEN 00
						AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2) 
								AND movim.cpbano= '2019'
								AND movim.CCCod like '12-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)
							end


					if(@nivel=5)
					begin 
						set @xvalor =
						(SELECT sum(movdebe-movhaber) 
								FROM CIS.softland.cwmovim  movim join cis.softland.cwcpbte b on movim.CpbNum=b.CpbNum  
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
								and b.CpbEst='V'
							AND  movim.cpbmes BETWEEN 00
						AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2) 
								AND movim.cpbano= '2019'
								AND movim.CCCod like '12-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)
						
						end

					if(@nivel=6)
					begin 
						set @xvalor =(SELECT sum(movdebe-movhaber) 
								FROM CIS.softland.cwmovim  movim join cis.softland.cwcpbte b on movim.CpbNum=b.CpbNum  
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
								and b.CpbEst='V'
							AND  movim.cpbmes BETWEEN 00
						AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2) 
								AND movim.cpbano= '2019'
								AND movim.CCCod like '12-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)
				    end


					if(@nivel=7)
					begin 
						set @xvalor = 
						(SELECT sum(movdebe-movhaber) 
								FROM CIS.softland.cwmovim  movim join cis.softland.cwcpbte b on movim.CpbNum=b.CpbNum  
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
								and b.CpbEst='V'
							AND  movim.cpbmes BETWEEN 00
						AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2) 
								AND movim.cpbano= '2019'
								AND movim.CCCod like '12-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)
							end


					if(@nivel=8)
					begin 
						set @xvalor = 

						(SELECT sum(movdebe-movhaber) 
								FROM CIS.softland.cwmovim  movim join cis.softland.cwcpbte b on movim.CpbNum=b.CpbNum  
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
								and b.CpbEst='V'
							AND  movim.cpbmes BETWEEN 00
						AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2) 
								AND movim.cpbano= '2019'
								AND movim.CCCod like '12-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)
					end

					if(@nivel=9)
					begin 
						set @xvalor = 
						(SELECT sum(movdebe-movhaber) 
								FROM CIS.softland.cwmovim  movim join cis.softland.cwcpbte b on movim.CpbNum=b.CpbNum  
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
								and b.CpbEst='V'
							AND  movim.cpbmes BETWEEN 00
						AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2) 
								AND movim.cpbano= '2019'
								AND movim.CCCod like '12-%')
							set @xvalor = ((@xvalor*@porcentaje)/100)
						end
			END	
		

			
		IF(@nivelEERR = 2)
			BEGIN
				--set @xvalor = '2'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] 
									where codiCC = @CCosto+'-000' 
									AND idCuenta = @nivel 
									AND BDSession = @bd 
									and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] 
									where codiCC = @CCosto+'-000' 
									AND idCuenta = @nivel 
									AND BDSession = @bd 
									and ano = @ano)

	if(@existeDist=1)
	begin
				
				if(@nivel=10)
				begin
					set @xvalor=(SELECT sum(movdebe-movhaber) 
								FROM CIS.softland.cwmovim  movim join cis.softland.cwcpbte b on movim.CpbNum=b.CpbNum  
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
								and b.CpbEst='V'
								AND  movim.cpbmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2)
								AND movim.cpbano=@ano 
								AND movim.CCCod like '11-%' )
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end
						
			

				if(@nivel=12)
				begin
				set @xvalor=(SELECT sum(movdebe-movhaber) 
								FROM CIS.softland.cwmovim  movim
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
								AND cpbmes BETWEEN '00' 
								AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2)
								AND cpbano=@ano 
								AND CCCod  like '11-%' )
				set @xvalor = ((@xvalor*@porcentaje)/100)
				end

			    if(@nivel=13)
				begin
				set @xvalor=(SELECT sum(movdebe-movhaber) 
							FROM CIS.softland.cwmovim movim
							WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
							AND  movim.cpbmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2)
							AND cpbano=@ano 
							AND CCCod  like '11-%')
					set @xvalor = ((@xvalor*@porcentaje)/100)
				end

				if(@nivel=14)
				begin
				set @xvalor=(SELECT sum(movdebe-movhaber) FROM CIS.softland.cwmovim movim WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									)  AND cpbmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2)
						AND cpbano=@ano 
						AND CCCod  like '11-%')
					set @xvalor = ((@xvalor*@porcentaje)/100)
				end

				if(@nivel=15)
				begin
					SET @xvalor=(	SELECT sum(movdebe-movhaber) 
									FROM CIS.softland.cwmovim  movim
									WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									AND cpbano=@ano 
									AND CCCod  like '11-%' 
									AND  movim.cpbmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2)
									AND cpbano=@ano 
									AND CCCod  like '11-%')
					set @xvalor = ((@xvalor*@porcentaje)/100)

				end
				
				if(@nivel=16)
				begin
				if(@porcentaje>0)
				begin
					set @xvalor=(SELECT sum(movdebe-movhaber) FROM CIS.softland.cwmovim movim WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
						AND  movim.cpbmes BETWEEN '00' AND RIGHT('00' + Ltrim(Rtrim(MONTH( convert(datetime,@fechahasta,103) ))),2)
						AND cpbano=@ano 
						AND CCCod  like '11-%')
					set @xvalor = ((@xvalor*@porcentaje)/100)
				end
				end
			end

						
						
			

			
	end	
		
		

		IF(@nivelEERR = 3)
			BEGIN
				--set @xvalor = '3'
			if(@existeDist>0)
			begin
					if(@nivel=17)
				begin
				set @xvalor = 
						(SELECT sum(movdebe-movhaber)
								FROM CIS.softland.cwmovim  movim join cis.softland.cwcpbte b on movim.CpbNum=b.CpbNum  
								
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									)
								and b.CpbEst='V'
								and  movim.cpbmes BETWEEN convert(datetime,@fechaDesde,103)
						 AND convert(datetime,@fechaHasta,103)
								AND movim.cpbano= @ano
								AND movim.CCCod like '01-%' )
						
					set @xvalor = ((@xvalor*@porcentaje)/100)
				end
				if(@nivel=18)
				begin
					set @xvalor = 
						( SELECT sum(movdebe-movhaber)
								FROM CIS.softland.cwmovim  movim  
								WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
							
								 AND  movim.cpbmes BETWEEN convert(datetime,@fechaDesde,103)
						 AND convert(datetime,@fechaHasta,103) and CCCod like '01-%')
							
				
					set @xvalor = ((@xvalor*@porcentaje)/100)
				end

				if(@nivel=26)
				begin
				set @xvalor = (SELECT sum(movdebe-movhaber)
						 FROM CIS.softland.cwmovim movim
						WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
						 AND  movim.cpbmes BETWEEN convert(datetime,@fechaDesde,103)
						 AND convert(datetime,@fechaHasta,103)
						 AND cpbano=@ano AND CCCod like '01-%' )
				
				end
		end
				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = (SELECT isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									AND movim.CpbFec BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' 
									AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
		
		end
				IF(@nivelEERR = 4)
			BEGIN
				--set @xvalor = '4'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND ano = @ano)
				set @xvalor = 
						(
							SELECT sum(MovDebe-movhaber)
									FROM CIS.softland.cwmovim movim join cis.softland.cwcpbte b on movim.CpbNum=b.CpbNum
									WHERE  movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									and movim.cpbano='2019'
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
						--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V' 
						AND movim.ccCod like ''+@CCosto+'%' AND b.CpbEst = 'V'

						)
				set @xvalor = ((@xvalor*@porcentaje)/100)
			end
		IF(@nivelEERR = 5)
			BEGIN
				--set @xvalor = '5'
				

				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
			if(@existeDist=1)
			begin
				set @xvalor = 
						(
							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				end

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END







				
				--IF(@nivel = 21 OR @nivel = 22 OR @nivel = 25)
				BEGIN
					set @xvalor = (@xvalor *-1)
				END
				

				IF(@nivel = 20)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

				IF(@nivel = 24)
				BEGIN
					IF(@xvalor >0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				end

				IF(@nivel = 25)
				BEGIN
					declare @xvalorDebe float
					declare @xvalorHaber float


					set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
					set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
					
					set @xvalorDebe = 
							(
								SELECT 
								isnull(sum(MovDebe),0) as resultadoSuma
								FROM CIS.softland.cwmovim movim 
								INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
								WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
									select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
							)

					
					set @xvalorHaber = 
							(
								SELECT 
								isnull(sum(MovHaber),0) as resultadoSuma
								FROM CIS.softland.cwmovim movim 
								INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
								WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
									select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
							)
					
					
			
					
					declare @sumaDiferencia float
					set @sumaDiferencia = (@xvalorHaber-@xvalorDebe)
					set @xvalor = ((@sumaDiferencia)*@porcentaje/100)
					--set @xvalor = '123456'
					end


					
					
					IF(@existeSuma > 0)
					BEGIN
						declare @xvalorDebeSuma float
						declare @xvalorHaberSuma float
						set @xvalorDebeSuma = 
									(
										SELECT 
										isnull(sum(MovDebe),0) as resultadoSuma
										FROM CIS.softland.cwmovim movim 
										INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
										INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
										WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
										AND movim.pctcod collate Modern_Spanish_CI_AS IN   
										(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
										) 
										and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
										--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
										AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
									)
						set @xvalorHaberSuma = 
									(
										SELECT 
										isnull(sum(MovHaber),0) as resultadoSuma
										FROM CIS.softland.cwmovim movim 
										INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
										INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
										WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
										AND movim.pctcod collate Modern_Spanish_CI_AS IN   
										(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
										) 
										and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
										--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
										AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
									)
					declare @sumaDiferenciaSuma float
					set @sumaDiferenciaSuma = (@xvalorHaberSuma-@xvalorDebeSuma)

						set @xvalor = (@xvalor + @sumaDiferenciaSuma)
						

					end
					

	

ELSE
	BEGIN

		
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
		set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
		set @xvalor = 
					(
						SELECT 
						isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
						FROM CIS.softland.cwmovim movim 
						INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
						INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
						WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
						AND movim.pctcod collate Modern_Spanish_CI_AS IN   
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
						) 
						and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
			
						AND movim.ccCod like ''+@CCosto+'%' AND cpbte.CpbEst = 'V'

						
							
					)
	set @xvalor = ((@xvalor*@porcentaje)/100)
		--set @xvalor = '777777'

	IF(@existeSuma > 0)
	BEGIN
		set @xvalorSuma = 
					(
						SELECT 
						isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
						FROM CIS.softland.cwmovim movim 
						INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
						INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
						WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
						AND movim.pctcod collate Modern_Spanish_CI_AS IN   
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
						) 
						and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
						--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V' 
						AND movim.ccCod like ''+@CCosto+'%' AND cpbte.CpbEst = 'V'

					)

		set @xvalor = (@xvalor + @xvalorSuma)
	END

	set @primerNivel = (select idNivel from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd  and ano = @ano)

		IF(@primerNivel = 0)
		BEGIN
			set @xvalor = (@xvalor *-1)
		END

		IF(@nivel = 25 or @nivel = 22)
		BEGIN
			set @xvalor = (@xvalor *-1)
		END

END

--select 13056852*10/100,13056852
--set @xvalor = (@xvalor)


END
if @xvalor = NULL
set @xvalor = 0
return @xvalor
end

GO
/****** Object:  UserDefinedFunction [dbo].[returnREALHORNILLAS]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnREALHORNILLAS](
@ano varchar(20),
@nivel varchar(10),
@fechaDesde varchar(15), 
@fechaHasta varchar(15),
@CCosto varchar(15),
@bd varchar(20),
@nivelEERR int

)
returns decimal
as
BEGIN
declare @xvalor decimal(20,1)
declare @xvalorSuma int
declare @existeDist int
declare @porcentaje float
declare @existeSuma int
declare @primerNivel int
declare @limpia int
declare @centrocostodist varchar(50)
set @existeDist = 
(
	--select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] 
	where codiCC = @CCosto+'-000' 
	AND idCuenta =  @nivel 
	AND valor <> '100' 
	AND valor <> '0' 
	AND BDSession = @bd 
	and ano = @ano
)
IF(@existeDist > 0)
	BEGIN
		--set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel)
		--select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '20-001' AND idCuenta = '4'
		--set @xvalor = ((@xvalor*@porcentaje)/100)	
		IF(@nivelEERR = 1)
			BEGIN
			
			--set @xvalor = '1'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd  and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							
							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd
							and SUBSTRING(movim.CcCod,1,2) collate Modern_Spanish_CI_AS in (select SUBSTRING(codicc,1,2) from DSCIS.DBO.ccdistribuible where idnivel=@nivelEERR )
	)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									AND movim.ccCod like @CCosto+'-%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
				--set @xvalor = (@xvalor *-1)
			END
		IF(@nivelEERR = 2)
			BEGIN
				--set @xvalor = '2'
			set @centrocostodist=(select codicc from DSCIS.DBO.ccdistribuible where idnivel=@nivelEERR and codicc= @CCosto)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							
							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd
			    			and SUBSTRING(movim.CcCod,1,2) collate Modern_Spanish_CI_AS in (select SUBSTRING(codicc,1,2) from DSCIS.DBO.ccdistribuible where idnivel=@nivelEERR and codicc= @CCosto)

						)
				set @xvalor = ((@xvalor*@porcentaje)/100)
				set @limpia=@xvalor
				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@limpia + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 3)
			BEGIN
				--set @xvalor = '3'
			set @centrocostodist=(select codicc from DSCIS.DBO.ccdistribuible where idnivel=@nivelEERR and codicc= @CCosto)
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							/*SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							--AND movim.ccCod = '01-001' AND cpbte.CpbEst = 'V' 
							AND movim.ccCod like '01%' AND cpbte.CpbEst = 'V'*/ 

							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
								and SUBSTRING(movim.CcCod,1,2) collate Modern_Spanish_CI_AS in (select SUBSTRING(codicc,1,2) from DSCIS.DBO.ccdistribuible where idnivel=@nivelEERR and codicc= @CCosto)

						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 4)
			BEGIN
				--set @xvalor = '4'
			set @centrocostodist=(select codicc from DSCIS.DBO.ccdistribuible where idnivel=@nivelEERR and codicc= @CCosto)
			
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							/*SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							--AND movim.ccCod = '01-001' AND cpbte.CpbEst = 'V'
							AND movim.ccCod like '01%' AND cpbte.CpbEst = 'V'*/

							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd

						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 5)
			BEGIN
				--set @xvalor = '5'
					if(@nivel=21)
				begin 
			
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
						)
				set @xvalor =(@xvalor*@porcentaje)/100
	


				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				end
				end
			else
				if(@nivel=24)
				begin 
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
						)
				set @xvalor =(@xvalor*@porcentaje)/100



				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				end
				end
			else
				begin 
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
							WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)



				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(Movhaber-Movdebe),0) as resultadoSuma
									FROM CIS.softland.cwmovim movim 
									INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
													select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
				end
			





				
				----IF(@nivel = 21 OR @nivel = 22 OR @nivel = 25)
				--BEGIN
				--	set @xvalor = (@xvalor *-1)
				--END
				

				IF(  @nivel = 22 OR @nivel = 25 or @nivel = 24)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
				
					END
				END

			

				IF(@nivel = 25)
				BEGIN
					declare @xvalorDebe float
					declare @xvalorHaber float


					set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
					set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
					/*
					set @xvalor = 
							(
								SELECT 
								isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
								FROM CIS.softland.cwmovim movim 
								INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
								WHERE movim.cpbano = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
									select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR
							)
					*/
					set @xvalorDebe = 
							(
								SELECT 
								isnull(sum(MovDebe),0) as resultadoSuma
								FROM CIS.softland.cwmovim movim 
								INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
								WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
												select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
							)

					
					set @xvalorHaber = 
							(
								SELECT 
								isnull(sum(MovHaber),0) as resultadoSuma
								FROM CIS.softland.cwmovim movim 
								INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
								WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
												select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR  AND ccnivel.BDSession =@bd
							)
					
					
					--set @xvalor = ((@xvalor*@porcentaje)/100)
					
					declare @sumaDiferencia float
					set @sumaDiferencia = (@xvalorHaber-@xvalorDebe)
					set @xvalor = ((@sumaDiferencia)*@porcentaje/100)
					--set @xvalor = '123456'



					
					
					IF(@existeSuma > 0)
					BEGIN
						declare @xvalorDebeSuma float
						declare @xvalorHaberSuma float
						set @xvalorDebeSuma = 
									(
										SELECT 
										isnull(sum(MovDebe),0) as resultadoSuma
										FROM CIS.softland.cwmovim movim 
										INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
										INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
										WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
										AND movim.pctcod collate Modern_Spanish_CI_AS IN   
										(
														select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
										) 
										and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
										--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
										AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
									)
						set @xvalorHaberSuma = 
									(
										SELECT 
										isnull(sum(MovHaber),0) as resultadoSuma
										FROM CIS.softland.cwmovim movim 
										INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
										INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
										WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
										AND movim.pctcod collate Modern_Spanish_CI_AS IN   
										(
														select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
										) 
										and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
										--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
										AND movim.ccCod like @CCosto+'%' AND cpbte.CpbEst = 'V'
									)
					declare @sumaDiferenciaSuma float
					set @sumaDiferenciaSuma = (@xvalorHaberSuma-@xvalorDebeSuma)

						set @xvalor = (@xvalor + @sumaDiferenciaSuma)
						
						--set @xvalor = '999999999'
					END
					




				END


				--set @xvalor = '999999999'
			END
	END
ELSE
	BEGIN
		--set @xvalor = '99999999999999'
		--select idNivel from [DSCIS].[dbo].[DS_DistribucionCC]
		
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
		set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
		set @xvalor = 
					(
						SELECT 
						isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
						FROM CIS.softland.cwmovim movim 
						INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
						INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
						WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
						AND movim.pctcod collate Modern_Spanish_CI_AS IN   
						(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
						) 
						and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
						--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
						AND movim.ccCod like ''+@CCosto+'%' AND cpbte.CpbEst = 'V'

						

					)
		set @xvalor = ((@xvalor*@porcentaje)/100)
		--set @xvalor = '777777'

	IF(@existeSuma > 0)
	BEGIN
		set @xvalorSuma = 
					(
						SELECT 
						isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
						FROM CIS.softland.cwmovim movim 
						INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
						INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
						WHERE movim.cpbano = @ano and cpbte.CpbAno = @ano
						AND movim.pctcod collate Modern_Spanish_CI_AS IN   
						(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
						) 
						and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
						--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V' 
						AND movim.ccCod like ''+@CCosto+'%' AND cpbte.CpbEst = 'V'

					)

		set @xvalor = (@xvalor + @xvalorSuma)
	END

	set @primerNivel = (select idNivel from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto+'-000' AND idCuenta = @nivel AND BDSession = @bd  and ano = @ano)

		IF(@primerNivel = 0)
		BEGIN
			set @xvalor = (@xvalor *-1)
		END

		IF(@nivel = 25 or @nivel = 22)
		BEGIN
			set @xvalor = (@xvalor *-1)
		END

END

--select 13056852*10/100,13056852
--set @xvalor = (@xvalor)
if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  UserDefinedFunction [dbo].[returnREALNUEVAHORNILLAS]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[returnREALNUEVAHORNILLAS](@ano varchar(20),@nivel varchar(10),@fechaDesde varchar(15), @fechaHasta varchar(15),@CCosto varchar(15),@bd varchar(20),@nivelEERR int)
returns int
as
BEGIN
declare @xvalor float(50)
declare @xvalorSuma float(50)
declare @existeDist int
declare @porcentaje float
declare @existeSuma int
declare @primerNivel int
set @existeDist = 
(
	--select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel
	select count(valor) as existeDist from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta =  @nivel AND valor <> '100' AND valor <> '0' AND BDSession = @bd and ano = @ano
)
IF(@existeDist > 0)
	BEGIN
		--set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel)
		--select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = '20-001' AND idCuenta = '4'
		--set @xvalor = ((@xvalor*@porcentaje)/100)	
		IF(@nivelEERR = 1)
			BEGIN
				--set @xvalor = '1'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd  and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							/*SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM NUEVAHORNILLAS.softland.cwmovim movim 
							INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND movim.ccCod like '12%' AND cpbte.CpbEst = 'V'*/
							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM NUEVAHORNILLAS.softland.cwmovim movim 
							INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON movim.ccCod collate Modern_Spanish_CI_AS = ccnivel.codiCC
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM NUEVAHORNILLAS.softland.cwmovim movim 
									INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
									WHERE movim.cpbano = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
				--set @xvalor = (@xvalor *-1)
			END
		IF(@nivelEERR = 2)
			BEGIN
				--set @xvalor = '2'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							/*SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM NUEVAHORNILLAS.softland.cwmovim movim 
							INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							--AND movim.ccCod = '11-001' AND cpbte.CpbEst = 'V'
							AND movim.ccCod like '11%' AND cpbte.CpbEst = 'V'*/

							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM NUEVAHORNILLAS.softland.cwmovim movim 
							INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON movim.ccCod collate Modern_Spanish_CI_AS = ccnivel.codiCC
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd

						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM NUEVAHORNILLAS.softland.cwmovim movim 
									INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 3)
			BEGIN
				--set @xvalor = '3'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							/*SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM NUEVAHORNILLAS.softland.cwmovim movim 
							INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							--AND movim.ccCod = '01-001' AND cpbte.CpbEst = 'V' 
							AND movim.ccCod like '01%' AND cpbte.CpbEst = 'V'*/ 

							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM NUEVAHORNILLAS.softland.cwmovim movim 
							INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON movim.ccCod collate Modern_Spanish_CI_AS = ccnivel.codiCC
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM NUEVAHORNILLAS.softland.cwmovim movim 
									INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 4)
			BEGIN
				--set @xvalor = '4'
				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							/*SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM NUEVAHORNILLAS.softland.cwmovim movim 
							INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							--AND movim.ccCod = '01-001' AND cpbte.CpbEst = 'V'
							AND movim.ccCod like '01%' AND cpbte.CpbEst = 'V'*/

							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM NUEVAHORNILLAS.softland.cwmovim movim 
							INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON movim.ccCod collate Modern_Spanish_CI_AS = ccnivel.codiCC
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd

						)
				set @xvalor = ((@xvalor*@porcentaje)/100)

				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM NUEVAHORNILLAS.softland.cwmovim movim 
									INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END
			END
		IF(@nivelEERR = 5)
			BEGIN
				--set @xvalor = '5'
				

				set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
				set @xvalor = 
						(
							SELECT 
							isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
							FROM NUEVAHORNILLAS.softland.cwmovim movim 
							INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
							INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON movim.ccCod collate Modern_Spanish_CI_AS = ccnivel.codiCC
							WHERE movim.cpbano = @ano
							AND movim.pctcod collate Modern_Spanish_CI_AS IN   
							(
								select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
							) 
							and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
							AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd
						)
				set @xvalor = ((@xvalor*@porcentaje)/100)



				IF(@existeSuma > 0)
				BEGIN
					set @xvalorSuma = 
								(
									SELECT 
									isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
									FROM NUEVAHORNILLAS.softland.cwmovim movim 
									INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
									INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
									WHERE movim.cpbano = @ano
									AND movim.pctcod collate Modern_Spanish_CI_AS IN   
									(
										select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
									) 
									and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
									--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
								)

					set @xvalor = (@xvalor + @xvalorSuma)
				END







				
				--IF(@nivel = 21 OR @nivel = 22 OR @nivel = 25)
				BEGIN
					set @xvalor = (@xvalor *-1)
				END
				

				IF(@nivel = 20)
				BEGIN
					IF(@xvalor <0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

				IF(@nivel = 24)
				BEGIN
					IF(@xvalor >0)
					BEGIN
						set @xvalor = (@xvalor *-1)
					END
				END

				IF(@nivel = 25)
				BEGIN
					declare @xvalorDebe float
					declare @xvalorHaber float


					set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
					set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
					/*
					set @xvalor = 
							(
								SELECT 
								isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
								FROM NUEVAHORNILLAS.softland.cwmovim movim 
								INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
								WHERE movim.cpbano = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
									select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR
							)
					*/
					set @xvalorDebe = 
							(
								SELECT 
								isnull(sum(MovDebe),0) as resultadoSuma
								FROM NUEVAHORNILLAS.softland.cwmovim movim 
								INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON movim.ccCod collate Modern_Spanish_CI_AS = ccnivel.codiCC
								WHERE movim.cpbano = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
									select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd
							)

					
					set @xvalorHaber = 
							(
								SELECT 
								isnull(sum(MovHaber),0) as resultadoSuma
								FROM NUEVAHORNILLAS.softland.cwmovim movim 
								INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
								INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
								INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON movim.ccCod collate Modern_Spanish_CI_AS = ccnivel.codiCC
								WHERE movim.cpbano = @ano
								AND movim.pctcod collate Modern_Spanish_CI_AS IN   
								(
									select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession =@bd
								) 
								and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
								AND cpbte.CpbEst = 'V' and ccnivel.idnivel=@nivelEERR AND ccnivel.BDSession =@bd
							)
					
					
					--set @xvalor = ((@xvalor*@porcentaje)/100)
					
					declare @sumaDiferencia float
					set @sumaDiferencia = (@xvalorHaber-@xvalorDebe)
					set @xvalor = ((@sumaDiferencia)*@porcentaje/100)
					--set @xvalor = '123456'



					
					
					IF(@existeSuma > 0)
					BEGIN
						declare @xvalorDebeSuma float
						declare @xvalorHaberSuma float
						set @xvalorDebeSuma = 
									(
										SELECT 
										isnull(sum(MovDebe),0) as resultadoSuma
										FROM NUEVAHORNILLAS.softland.cwmovim movim 
										INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
										INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
										WHERE movim.cpbano = @ano
										AND movim.pctcod collate Modern_Spanish_CI_AS IN   
										(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
										) 
										and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
										--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
										AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									)
						set @xvalorHaberSuma = 
									(
										SELECT 
										isnull(sum(MovHaber),0) as resultadoSuma
										FROM NUEVAHORNILLAS.softland.cwmovim movim 
										INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
										INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
										WHERE movim.cpbano = @ano
										AND movim.pctcod collate Modern_Spanish_CI_AS IN   
										(
											select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
										) 
										and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
										--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
										AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
									)
					declare @sumaDiferenciaSuma float
					set @sumaDiferenciaSuma = (@xvalorHaberSuma-@xvalorDebeSuma)

						set @xvalor = (@xvalor + @sumaDiferenciaSuma)
						
						--set @xvalor = '999999999'
					END
					




				END


				--set @xvalor = '999999999'
			END
	END
ELSE
	BEGIN
		--set @xvalor = '99999999999999'
		--select idNivel from [DSCIS].[dbo].[DS_DistribucionCC]
		
		set @existeSuma = (select Suma from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
		set @porcentaje = (select valor from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd and ano = @ano)
		set @xvalor = 
					(
						SELECT 
						isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
						FROM NUEVAHORNILLAS.softland.cwmovim movim 
						INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
						INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
						WHERE movim.cpbano = @ano
						AND movim.pctcod collate Modern_Spanish_CI_AS IN   
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
						) 
						and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
						--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'
						AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'

						

					)
		set @xvalor = ((@xvalor*@porcentaje)/100)
		--set @xvalor = '777777'

	IF(@existeSuma > 0)
	BEGIN
		set @xvalorSuma = 
					(
						SELECT 
						isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
						FROM NUEVAHORNILLAS.softland.cwmovim movim 
						INNER JOIN NUEVAHORNILLAS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
						INNER JOIN NUEVAHORNILLAS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum
						WHERE movim.cpbano = @ano
						AND movim.pctcod collate Modern_Spanish_CI_AS IN   
						(
							select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = @nivel AND BDSession = @bd
						) 
						and movim.CpbFec  BETWEEN convert(datetime,@fechaDesde,103) AND convert(datetime,@fechaHasta,103) 
						--AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V' 
						AND movim.ccCod = @CCosto AND cpbte.CpbEst = 'V'

					)

		set @xvalor = (@xvalor + @xvalorSuma)
	END

	set @primerNivel = (select idNivel from [DSCIS].[dbo].[DS_DistribucionCC] where codiCC = @CCosto AND idCuenta = @nivel AND BDSession = @bd  and ano = @ano)

		IF(@primerNivel = 0)
		BEGIN
			set @xvalor = (@xvalor *-1)
		END
	END

--select 13056852*10/100,13056852
--set @xvalor = (@xvalor)
if @xvalor = NULL
set @xvalor = 0
return @xvalor

END
GO
/****** Object:  Table [dbo].[CCDistribuible]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CCDistribuible](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idnivel] [int] NULL,
	[codicc] [varchar](50) NULL,
	[BdSession] [varchar](50) NULL,
 CONSTRAINT [PK_CCDistribuible] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ccodis]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ccodis](
	[ccodi] [varchar](50) NULL,
	[idnivel] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DS_AGRUPABKP]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DS_AGRUPABKP](
	[idNivel] [int] NULL,
	[PCCODI] [varchar](50) NULL,
	[descTitulo] [varchar](50) NULL,
	[descTotal] [varchar](50) NULL,
	[BDSession] [varchar](50) NULL,
	[id] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DS_AGRUPACION_CUENTAS_CLON]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DS_AGRUPACION_CUENTAS_CLON](
	[idnivel] [int] NULL,
	[PCCODI] [varchar](50) NULL,
	[descTitulo] [varchar](50) NULL,
	[BDSession] [varchar](50) NULL,
	[mes] [varchar](50) NULL,
	[ano] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DS_AgrupacionCCNivel]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DS_AgrupacionCCNivel](
	[idDS_AgrupacionCC] [int] IDENTITY(1,1) NOT NULL,
	[CodiCC] [nchar](8) NULL,
	[idnivel] [int] NULL,
	[bdsession] [varchar](30) NULL,
 CONSTRAINT [PK_DS_AgrupacionCCNivel] PRIMARY KEY CLUSTERED 
(
	[idDS_AgrupacionCC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DS_AgrupacionCuentas]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DS_AgrupacionCuentas](
	[idNivel] [int] NULL,
	[PCCODI] [varchar](50) NULL,
	[descTitulo] [varchar](50) NULL,
	[descTotal] [varchar](50) NULL,
	[BDSession] [varchar](50) NULL,
	[MES] [varchar](50) NULL,
	[ANO] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DS_DISTRIBUCION_CUENTAS_CLON]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DS_DISTRIBUCION_CUENTAS_CLON](
	[id] [int] NULL,
	[idCuenta] [int] NULL,
	[valor] [varchar](50) NULL,
	[CodiCC] [varchar](50) NULL,
	[idnivel] [int] NULL,
	[suma] [int] NULL,
	[BDSession] [varchar](50) NULL,
	[ano] [varchar](50) NULL,
	[mes] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DS_DistribucionCC]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DS_DistribucionCC](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idCuenta] [int] NULL,
	[valor] [varchar](50) NULL,
	[CodiCC] [varchar](50) NULL,
	[idNivel] [int] NULL,
	[Suma] [int] NULL,
	[BDSession] [varchar](50) NULL,
	[ano] [varchar](50) NULL,
	[mes] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ds_distribucionCC_bkp]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ds_distribucionCC_bkp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idCuenta] [int] NULL,
	[valor] [varchar](50) NULL,
	[CodiCC] [varchar](50) NULL,
	[idNivel] [int] NULL,
	[Suma] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DS_DistribucionCC123]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DS_DistribucionCC123](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idCuenta] [int] NULL,
	[valor] [varchar](50) NULL,
	[CodiCC] [varchar](50) NULL,
	[idNivel] [int] NULL,
	[Suma] [int] NULL,
	[BDSession] [varchar](50) NULL,
	[ano] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DS_DistribucionCCAnoSiguiente]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DS_DistribucionCCAnoSiguiente](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idCuenta] [int] NULL,
	[valor] [varchar](50) NULL,
	[CodiCC] [varchar](50) NULL,
	[idNivel] [int] NULL,
	[Suma] [int] NULL,
	[BDSession] [varchar](50) NULL,
	[ano] [varchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DS_nivelesEERR]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DS_nivelesEERR](
	[idNivel] [int] NULL,
	[idCuenta] [int] NULL,
	[tituloNivel] [varchar](50) NULL,
	[descripcionNivel] [varchar](50) NULL,
	[orden] [int] NULL,
	[bdsession] [varchar](50) NULL,
	[id] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DS_nivelesEERR_backup]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DS_nivelesEERR_backup](
	[idNivel] [int] NULL,
	[idCuenta] [int] NULL,
	[tituloNivel] [varchar](50) NULL,
	[descripcionNivel] [varchar](50) NULL,
	[orden] [int] NULL,
	[bdsession] [varchar](50) NULL,
	[id] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DS_Usuarios]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DS_Usuarios](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Usuario] [varchar](10) NOT NULL,
	[Contrasena] [varbinary](max) NULL,
	[Cliente] [varchar](50) NULL,
	[CCosto] [varchar](50) NULL,
	[email] [varchar](50) NULL,
	[tipoUsuario] [varchar](50) NULL,
	[nombres] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DS_UsuariosTipos]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DS_UsuariosTipos](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[tipoUsuario] [varchar](20) NOT NULL,
	[urlInicio] [varchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NivelesDistribucion]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NivelesDistribucion](
	[IdNivel] [int] NOT NULL,
	[NivelEERR] [varchar](50) NULL,
 CONSTRAINT [PK_NivelesDistribucion_1] PRIMARY KEY CLUSTERED 
(
	[IdNivel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Parametros]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Parametros](
	[impuesto] [decimal](4, 2) NULL,
	[mes] [varchar](4) NULL,
	[ano] [varchar](4) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[registrarimpuesto]    Script Date: 11-12-2019 12:59:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[registrarimpuesto](
	[impuesto] [float] NULL,
	[mes] [varchar](2) NULL,
	[ano] [varchar](4) NULL
) ON [PRIMARY]
GO
USE [master]
GO
ALTER DATABASE [DSCIS] SET  READ_WRITE 
GO
