<#
.SYNOPSIS
    Instalador Oficial, Actualizador y Gestor de Resiliencia de Goulm CLI para Windows.
.DESCRIPTION
    Instalador de nivel profesional con arquitectura 'Zero Dead-Ends' (cero callejones sin salida),
    soporte trilingue para las Americas (ES / EN / PT-BR), paso previo de aceptacion de licencia,
    fallback automatico ante caidas de API, gestion de procesos bloqueantes, validacion de integridad ZIP,
    soporte de rollback automatico de 1 version y opciones estrategicas de donacion comunitaria.
.PARAMETER Uninstall
    Desinstala Goulm limpiando el PATH de Windows y los archivos locales.
.PARAMETER Rollback
    Restaura la version inmediatamente anterior desde el respaldo local.
.PARAMETER Force
    Fuerza la reinstalacion omitiendo confirmaciones interactivas.
.PARAMETER AcceptLicense
    Acepta automaticamente los terminos de la licencia EULA sin preguntar interactivamente.
.PARAMETER Lang
    Idioma forzado: 'es' (Espanol), 'en' (English), 'pt' (Portugues do Brasil).
#>
[CmdletBinding()]
param(
    [switch]$Uninstall,
    [switch]$Rollback,
    [switch]$Force,
    [switch]$AcceptLicense,
    [string]$Lang = ""
)

# Optimizacion de transporte y codificacion de consola
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

# Silenciar barra interna de PS5.1 para evitar ralentizacion de red de 10x
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

$Repo = "LRGolden/Goulm_packages"
$InstallDir = "$env:LOCALAPPDATA\Programs\Goulm"
$ExeTarget = "$InstallDir\goulm.exe"
$BackupExe = "$InstallDir\goulm.exe.bak"
$BackupVer = "$InstallDir\.version.bak"

# -----------------------------------------------------------------------------
# 1. Sistema Multi-idioma de las Americas (ES / EN / PT)
# -----------------------------------------------------------------------------
if (-not $Lang) {
    try {
        $uiLang = (Get-UICulture).TwoLetterISOLanguageName.ToLower()
        if ($uiLang -eq "es") { $Lang = "es" }
        elseif ($uiLang -eq "pt") { $Lang = "pt" }
        else { $Lang = "en" }
    } catch {
        $Lang = "es"
    }
} else {
    $Lang = $Lang.ToLower()
    if ($Lang -notin @("es", "en", "pt")) { $Lang = "en" }
}

$I18N = @{
    es = @{
        SubTitle = "Entorno Integrado de Agente (AIE) de Terminal para las Americas"
        AnalysisHeader = ">>> [FASE 1/4] ANALISIS DE ENTORNO Y SISTEMA"
        ArchDetected = "Arquitectura nativa del procesador : {0}"
        ProcessRunning = "PROCESO BLOQUEADO: 'goulm.exe' se encuentra actualmente en ejecucion."
        AskKillProcess = "Deseas que el instalador cierre 'goulm.exe' (PID: {0}) para continuar? [s/N]: "
        ProcessWait = "Esperando que se libere el archivo 'goulm.exe'..."
        ProcessKillManual = "Para cerrarlo manualmente ejecuta: taskkill /IM goulm.exe /F"
        ProcessAbort = "No se pudo actualizar porque 'goulm.exe' esta en uso. Cierralo e intenta nuevamente."
        LocalInstallFound = "Instalacion previa detectada        : {0}"
        NoPreviousInstall = "Estado de instalacion               : Instalacion limpia (primera vez)"
        BackupFound = "Respaldo previo disponible          : Version {0}"
        LicenseHeader = ">>> [TERMINOS DE LICENCIA Y CONDICIONES DE USO]"
        LicenseSummaryPoint1 = "• GRATUITO: Desarrolladores individuales (Indies), freelancers personales y proyectos academicos."
        LicenseSummaryPoint2 = "• COMERCIAL: Toda empresa o persona juridica (incluidas empresas unipersonales / 'one-person') requiere Licencia Comercial."
        LicenseSummaryPoint3 = "• SUPERVISION: Goulm utiliza modelos de IA; el usuario debe inspeccionar y aprobar cada comando antes de ejecutarlo."
        LicenseSummaryPoint4 = "• SIN GARANTIA: El software se proporciona 'TAL CUAL' (AS IS). LRGolden no asume responsabilidad por daños o perdidas."
        LicensePrompt = "Selecciona una opcion ([s] Acepto y continuar | [v] Ver texto completo | [n] Cancelar): "
        LicenseRejected = "Has rechazado los terminos de la licencia. Instalacion cancelada."
        QueryingRelease = ">>> [FASE 2/4] CONSULTA DE RELEASES Y COMPATIBILIDAD"
        ConnectingGitHub = "Consultando canal oficial ({0})..."
        ApiRateLimitFallback = "Aviso: Cuota de API excedida. Activando canal de descarga directa de emergencia..."
        LatestVersionFound = "Ultima version detectada            : {0}"
        AssetSpecs = "Paquete compatible seleccionado     : {0} ({1} MB)"
        AlreadyUpToDate = "Goulm ya se encuentra en su version mas reciente ({0})."
        AskReinstall = "Deseas forzar la reinstalacion completa? [s/N]: "
        AskRollback = "Se detecto un respaldo de la version anterior ({0}). Deseas restaurarla ahora? [s/N]: "
        RollbackStart = "Restaurando version anterior desde el respaldo local..."
        RollbackSuccess = "Rollback completado con exito. Version activa: {0}"
        RollbackNotFound = "No se encontro ningun respaldo previo para restaurar."
        InstallPlan = ">>> [FASE 3/4] PLAN DE DESPLIEGUE Y DESCARGA"
        DownloadTarget = "Descargando binario y documentacion legal..."
        ExtractingTarget = "Descomprimiendo archivos y generando respaldo de seguridad..."
        ZipCorrupted = "El paquete descargado parece estar incompleto o dañado. Reintentando..."
        ZipFailedCompletely = "No se pudo validar el archivo ZIP tras multiples intentos."
        AntivirusWarning = "AVISO DE SEGURIDAD (ANTIVIRUS / SMARTSCREEN):"
        AntivirusHelp = "Si tu antivirus o Windows Defender bloqueo el archivo, ejecuta: Unblock-File '{0}'"
        UpdatingPath = "Registrando ruta permanente en el PATH de usuario..."
        Broadcasting = "Enviando senal de actualizacion de entorno a Windows..."
        FinalHeader = "=========================================================================="
        SuccessTitle = "GOULM CLI INSTALADO Y VERIFICADO EXITOSAMENTE"
        InstalledVersion = "Version activa  : {0}"
        InstallPath = "Directorio base : {0}"
        TreeHeader = "Desglose de archivos instalados:"
        TreeExe = "├── [EJECUTABLE] goulm.exe"
        TreeReadme = "├── [DOCUMENTO]  README.md"
        TreeLegal = "├── [LEGAL]      legal/LICENSE (EULA y terminos comerciales)"
        TreeNotices = "├── [TERCEROS]   legal/THIRD_PARTY_NOTICES.md (atribuciones Go/npm)"
        TreeDonate = "├── [APOYO]      legal/DONATE.md (canales de donacion)"
        TreeUninst = "└── [CONTROL]    uninstall.ps1 (desinstalador local)"
        DonateHeader = "☕ APOYA EL DESARROLLO INDEPENDIENTE (KO-FI):"
        DonateKofi = "• Ko-fi : https://ko-fi.com/dorado44"
        TipsHeader = "CONSEJOS OPERATIVOS Y AVISOS DE SEGURIDAD (IA):"
        Tip1 = "[Supervision de IA] Goulm utiliza modelos LLM avanzados. Revisa siempre los comandos antes de aprobar mutaciones o commits en tu codigo."
        Tip2 = "[Credenciales] Tus API keys se almacenan cifradas localmente con AES-256-GCM / DPAPI. Nunca se envian a servidores de LRGolden."
        Tip3 = "[Conexion rapida] Ejecuta '/connect' dentro de Goulm para configurar OpenRouter, Anthropic o DeepSeek."
        Tip4 = "[Respaldo] Ante cualquier anomalia, puedes volver a correr este instalador con '-Rollback' para volver a la version previa."
        NextSteps = "COMO EMPEZAR:"
        Step1 = "1. Abre una nueva consola (CMD, PowerShell o Windows Terminal)."
        Step2 = "2. Escribe 'goulm' y presiona Enter."
        ManualEscapeTitle = "GUIA DE RECUPERACION MANUAL (RUTA DE ESCAPE):"
        ManualEscapeDesc = "Si tu conexion bloquea scripts, puedes descargar el ZIP manualmente desde:"
        ManualEscapeFolder = "Y extraer su contenido dentro de:"
        UninstallHeader = ">>> DESINSTALACION DE GOULM"
        UninstallCleanPath = "Limpiando variable PATH de usuario..."
        UninstallRemoveFiles = "Eliminando directorio y respaldos..."
        UninstallDone = "Goulm y todos sus componentes han sido removidos del equipo."
    }
    en = @{
        SubTitle = "Terminal Agent Integrated Environment (AIE) for the Americas"
        AnalysisHeader = ">>> [PHASE 1/4] SYSTEM AND ENVIRONMENT ANALYSIS"
        ArchDetected = "Native Processor Architecture      : {0}"
        ProcessRunning = "BLOCKED PROCESS: 'goulm.exe' is currently running."
        AskKillProcess = "Do you want the installer to close 'goulm.exe' (PID: {0}) to continue? [y/N]: "
        ProcessWait = "Waiting for 'goulm.exe' to release file locks..."
        ProcessKillManual = "To close it manually run: taskkill /IM goulm.exe /F"
        ProcessAbort = "Could not update because 'goulm.exe' is in use. Please close it and retry."
        LocalInstallFound = "Existing Installation Detected     : {0}"
        NoPreviousInstall = "Installation State                 : Clean install (first time)"
        BackupFound = "Previous Backup Available          : Version {0}"
        LicenseHeader = ">>> [LICENSE TERMS AND CONDITIONS OF USE]"
        LicenseSummaryPoint1 = "• FREE USE: Individual developers (Indies), personal freelancers, and academic research."
        LicenseSummaryPoint2 = "• COMMERCIAL: Any company or business entity (including one-person companies) requires a Commercial License."
        LicenseSummaryPoint3 = "• SUPERVISION: Goulm uses AI models; user must inspect and verify every command before execution."
        LicenseSummaryPoint4 = "• AS IS: Software provided without warranties. LRGolden assumes no liability for damages or losses."
        LicensePrompt = "Choose an option ([y] Accept and continue | [v] View full text | [n] Cancel): "
        LicenseRejected = "License terms rejected. Installation aborted."
        QueryingRelease = ">>> [PHASE 2/4] REMOTE RELEASE QUERY & COMPATIBILITY"
        ConnectingGitHub = "Querying official channel ({0})..."
        ApiRateLimitFallback = "Notice: API rate limit exceeded. Activating emergency direct download channel..."
        LatestVersionFound = "Latest Detected Version            : {0}"
        AssetSpecs = "Selected Compatible Package        : {0} ({1} MB)"
        AlreadyUpToDate = "Goulm is already up to date ({0})."
        AskReinstall = "Do you want to force a full reinstallation? [y/N]: "
        AskRollback = "A backup of previous version ({0}) was detected. Do you want to rollback now? [y/N]: "
        RollbackStart = "Restoring previous version from local backup..."
        RollbackSuccess = "Rollback completed successfully. Active version: {0}"
        RollbackNotFound = "No previous backup found to restore."
        InstallPlan = ">>> [PHASE 3/4] DEPLOYMENT AND DOWNLOAD PLAN"
        DownloadTarget = "Downloading binary and legal documentation..."
        ExtractingTarget = "Extracting files and creating safety backup..."
        ZipCorrupted = "Downloaded package appears incomplete or corrupt. Retrying..."
        ZipFailedCompletely = "Could not validate ZIP archive after multiple attempts."
        AntivirusWarning = "SECURITY NOTICE (ANTIVIRUS / SMARTSCREEN):"
        AntivirusHelp = "If your antivirus or Windows Defender blocked the file, run: Unblock-File '{0}'"
        UpdatingPath = "Registering permanent path in Windows User PATH..."
        Broadcasting = "Broadcasting environment change signal to Windows..."
        FinalHeader = "=========================================================================="
        SuccessTitle = "GOULM CLI INSTALLED AND VERIFIED SUCCESSFULLY"
        InstalledVersion = "Active Version  : {0}"
        InstallPath = "Base Directory  : {0}"
        TreeHeader = "Installed Components Breakdown:"
        TreeExe = "├── [EXECUTABLE] goulm.exe"
        TreeReadme = "├── [DOCS]       README.md"
        TreeLegal = "├── [LEGAL]      legal/LICENSE (EULA & commercial terms)"
        TreeNotices = "├── [NOTICES]    legal/THIRD_PARTY_NOTICES.md (Go/npm attributions)"
        TreeDonate = "├── [SUPPORT]    legal/DONATE.md (donation channels)"
        TreeUninst = "└── [CONTROL]    uninstall.ps1 (local uninstaller)"
        DonateHeader = "☕ SUPPORT INDEPENDENT DEVELOPMENT (KO-FI):"
        DonateKofi = "• Ko-fi : https://ko-fi.com/dorado44"
        TipsHeader = "OPERATIONAL TIPS & AI SAFETY GUIDELINES:"
        Tip1 = "[AI Supervision] Goulm uses advanced LLMs. Always inspect suggested commands before approving mutations or commits."
        Tip2 = "[Security] Your API keys are encrypted locally using AES-256-GCM / DPAPI. Never sent to LRGolden servers."
        Tip3 = "[Quick Setup] Run '/connect' inside Goulm to configure OpenRouter, Anthropic, or DeepSeek."
        Tip4 = "[Safe Rollback] If an update causes issues, rerun this installer with '-Rollback' to instantly restore your previous version."
        NextSteps = "GETTING STARTED:"
        Step1 = "1. Open a new terminal (CMD, PowerShell, or Windows Terminal)."
        Step2 = "2. Type 'goulm' and press Enter."
        ManualEscapeTitle = "MANUAL RECOVERY GUIDE (ESCAPE ROUTE):"
        ManualEscapeDesc = "If your network blocks scripts, you can manually download the ZIP from:"
        ManualEscapeFolder = "And extract its contents inside:"
        UninstallHeader = ">>> GOULM UNINSTALLATION"
        UninstallCleanPath = "Cleaning User PATH environment variable..."
        UninstallRemoveFiles = "Removing application directory and backups..."
        UninstallDone = "Goulm and all associated components have been completely uninstalled."
    }
    pt = @{
        SubTitle = "Ambiente Integrado de Agente (AIE) de Terminal para as Americas"
        AnalysisHeader = ">>> [FASE 1/4] ANALISE DE AMBIENTE E SISTEMA"
        ArchDetected = "Arquitetura nativa do processador  : {0}"
        ProcessRunning = "PROCESSO BLOQUEADO: 'goulm.exe' esta em execucao no momento."
        AskKillProcess = "Deseja que o instalador encerre 'goulm.exe' (PID: {0}) para prosseguir? [s/N]: "
        ProcessWait = "Aguardando liberacao do executavel 'goulm.exe'..."
        ProcessKillManual = "Para fechar manualmente execute: taskkill /IM goulm.exe /F"
        ProcessAbort = "Nao foi possivel atualizar pois 'goulm.exe' esta em uso. Feche-o e tente novamente."
        LocalInstallFound = "Instalacao existente detectada     : {0}"
        NoPreviousInstall = "Status de Instalacao               : Instalacao limpa (primeira vez)"
        BackupFound = "Backup anterior disponivel         : Versao {0}"
        LicenseHeader = ">>> [TERMOS DE LICENCA E CONDICOES DE USO]"
        LicenseSummaryPoint1 = "• GRATUITO: Desenvolvedores individuais (Indies), freelancers pessoais e fins academicos."
        LicenseSummaryPoint2 = "• COMERCIAL: Empresas e pessoas juridicas (incluindo empresas unipessoais) necessitam de Licenca Comercial."
        LicenseSummaryPoint3 = "• SUPERVISAO: O Goulm utiliza IA; o usuario deve revisar e aprovar comandos antes da execucao."
        LicenseSummaryPoint4 = "• AS IS: Fornecido 'COMO ESTA'. A LRGolden nao assume responsabilidade por perdas ou danos."
        LicensePrompt = "Escolha uma opcao ([s] Aceitar e continuar | [v] Ver texto completo | [n] Cancelar): "
        LicenseRejected = "Termos de licenca rejeitados. Instalacao cancelada."
        QueryingRelease = ">>> [FASE 2/4] CONSULTA DE VERSOES E COMPATIBILIDADE"
        ConnectingGitHub = "Consultando canal oficial ({0})..."
        ApiRateLimitFallback = "Aviso: Limite de requisicoes da API atingido. Ativando canal direto de download..."
        LatestVersionFound = "Ultima versao detectada            : {0}"
        AssetSpecs = "Pacote compativel selecionado      : {0} ({1} MB)"
        AlreadyUpToDate = "O Goulm ja esta atualizado na versao mais recente ({0})."
        AskReinstall = "Deseja forcar uma reinstalacao completa? [s/N]: "
        AskRollback = "Foi encontrado um backup da versao anterior ({0}). Deseja restaura-la agora? [s/N]: "
        RollbackStart = "Restaurando versao anterior a partir do backup local..."
        RollbackSuccess = "Rollback concluido com sucesso. Versao ativa: {0}"
        RollbackNotFound = "Nenhum backup anterior foi encontrado."
        InstallPlan = ">>> [FASE 3/4] PLANO DE IMPLANTACAO E DOWNLOAD"
        DownloadTarget = "Baixando executavel e documentacao legal..."
        ExtractingTarget = "Extraindo arquivos e gerando backup seguro..."
        ZipCorrupted = "O pacote baixado parece incompleto ou corrompido. Tentando novamente..."
        ZipFailedCompletely = "Nao foi possivel validar o arquivo ZIP apos multiplas tentativas."
        AntivirusWarning = "AVISO DE SEGURANCA (ANTIVIRUS / SMARTSCREEN):"
        AntivirusHelp = "Se o seu antivirus ou Windows Defender reteve o arquivo, execute: Unblock-File '{0}'"
        UpdatingPath = "Registrando caminho permanente no PATH do usuario..."
        Broadcasting = "Notificando o Windows para atualizar variaveis de ambiente..."
        FinalHeader = "=========================================================================="
        SuccessTitle = "GOULM CLI INSTALADO E VERIFICADO COM SUCESSO"
        InstalledVersion = "Versao Ativa    : {0}"
        InstallPath = "Diretorio Base  : {0}"
        TreeHeader = "Detalhamento dos componentes instalados:"
        TreeExe = "├── [EXECUTAVEL] goulm.exe"
        TreeReadme = "├── [DOCS]       README.md"
        TreeLegal = "├── [LEGAL]      legal/LICENSE (EULA e termos comerciais)"
        TreeNotices = "├── [NOTICES]    legal/THIRD_PARTY_NOTICES.md (atribuicoes Go/npm)"
        TreeDonate = "├── [APOIO]      legal/DONATE.md (canais de contribuicao)"
        TreeUninst = "└── [CONTROLE]   uninstall.ps1 (desinstalador local)"
        DonateHeader = "☕ APOIE O DESENVOLVIMENTO INDEPENDENTE (KO-FI):"
        DonateKofi = "• Ko-fi : https://ko-fi.com/dorado44"
        TipsHeader = "DICAS OPERACIONAIS E DIRETRIZES DE IA:"
        Tip1 = "[Supervisao de IA] O Goulm utiliza modelos de IA avancados. Sempre revise comandos sugeridos antes de aprovar alteracoes."
        Tip2 = "[Seguranca] Suas chaves de API sao protegidas localmente com criptografia AES-256-GCM / DPAPI."
        Tip3 = "[Inicio rapido] Execute '/connect' dentro do Goulm para configurar provedores como OpenRouter ou DeepSeek."
        Tip4 = "[Rollback seguro] Caso uma atualizacao apresente instabilidade, execute o instalador com '-Rollback' para reverter."
        NextSteps = "COMO INICIAR:"
        Step1 = "1. Abra um novo terminal (CMD, PowerShell ou Windows Terminal)."
        Step2 = "2. Digite 'goulm' e pressione Enter."
        ManualEscapeTitle = "GUIA DE RECUPERACAO MANUAL (ROTA DE FUGA):"
        ManualEscapeDesc = "Se a sua rede bloquear scripts, voce pode baixar o ZIP manualmente em:"
        ManualEscapeFolder = "E extrair seu conteudo dentro de:"
        UninstallHeader = ">>> DESINSTALACAO DO GOULM"
        UninstallCleanPath = "Limpando variavel PATH do usuario..."
        UninstallRemoveFiles = "Removendo arquivos e backups..."
        UninstallDone = "O Goulm foi completamente desinstalado do seu sistema."
    }
}
$T = $I18N[$Lang]

# -----------------------------------------------------------------------------
# 2. Funciones Graficas y del Sistema
# -----------------------------------------------------------------------------
function Show-Banner {
    Write-Host ""
    Write-Host "  ██████╗  ██████╗ ██╗   ██╗██╗     ███╗   ███╗" -ForegroundColor Cyan
    Write-Host " ██╔════╝ ██╔═══██╗██║   ██║██║     ████╗ ████║" -ForegroundColor Cyan
    Write-Host " ██║  ███╗██║   ██║██║   ██║██║     ██╔████╔██║" -ForegroundColor Cyan
    Write-Host " ██║   ██║██║   ██║██║   ██║██║     ██║╚██╔╝██║" -ForegroundColor Cyan
    Write-Host " ╚██████╔╝╚██████╔╝╚██████╔╝███████╗██║ ╚═╝ ██║" -ForegroundColor Cyan
    Write-Host "  ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝╚═╝     ╚═╝" -ForegroundColor Cyan
    Write-Host "  $($T.SubTitle)" -ForegroundColor DarkCyan
    Write-Host "  Distribuicao Oficial: https://github.com/$Repo" -ForegroundColor DarkGray
    Write-Host ""
}

function Test-IsInteractive {
    try {
        return (-not [Console]::IsInputRedirected) -and ($Host.UI.RawUI.KeyAvailable -ne $null)
    } catch {
        return $false
    }
}

function Show-EscapeRoute {
    param([string]$DownloadUrl)
    Write-Host ""
    Write-Host "--------------------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host " [?] $($T.ManualEscapeTitle)" -ForegroundColor Yellow
    Write-Host "     $($T.ManualEscapeDesc)" -ForegroundColor Gray
    Write-Host "     $DownloadUrl" -ForegroundColor Cyan
    Write-Host "     $($T.ManualEscapeFolder)" -ForegroundColor Gray
    Write-Host "     $InstallDir" -ForegroundColor White
    Write-Host "--------------------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host ""
}

function Broadcast-EnvironmentChange {
    try {
        if (-not ("Win32.NativeMethods" -as [type])) {
            Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
            [System.Runtime.InteropServices.DllImport("user32.dll", SetLastError = true, CharSet = System.Runtime.InteropServices.CharSet.Auto)]
            public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
"@ -ErrorAction SilentlyContinue
        }
        $HWND_BROADCAST = [IntPtr]0xffff
        $WM_SETTINGCHANGE = 0x001A
        $result = [UIntPtr]::Zero
        [Win32.NativeMethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, "Environment", 2, 3000, [ref]$result) | Out-Null
    } catch {}
}

function Resolve-RunningProcess {
    $proc = Get-Process goulm -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($proc) {
        Write-Host "`n[!] $($T.ProcessRunning)" -ForegroundColor Yellow
        if (Test-IsInteractive -and -not $Force) {
            $killPrompt = Read-Host ($T.AskKillProcess -f $proc.Id)
            if ($killPrompt -match '^[sSyY]$') {
                try {
                    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 1
                } catch {}
            }
        }
        
        $procStillAlive = Get-Process goulm -ErrorAction SilentlyContinue
        if ($procStillAlive) {
            Write-Host "    $($T.ProcessWait)" -ForegroundColor Gray
            Write-Host "    $($T.ProcessKillManual)" -ForegroundColor DarkGray
            $retries = 0
            while ($procStillAlive -and $retries -lt 6) {
                Start-Sleep -Seconds 2
                $procStillAlive = Get-Process goulm -ErrorAction SilentlyContinue
                $retries++
            }
            if ($procStillAlive) {
                Write-Error $T.ProcessAbort
                exit 1
            }
        }
    }
}

function Test-ZipIntegrity {
    param([string]$ZipPath)
    if (-not (Test-Path $ZipPath)) { return $false }
    $fileInfo = Get-Item $ZipPath
    if ($fileInfo.Length -lt 1MB) { return $false }
    try {
        $stream = [System.IO.File]::OpenRead($ZipPath)
        $bytes = New-Object byte[] 4
        $read = $stream.Read($bytes, 0, 4)
        $stream.Close()
        if ($bytes[0] -eq 0x50 -and $bytes[1] -eq 0x4B) { return $true }
    } catch {
        return $false
    }
    return $false
}

function Assert-LicenseAccepted {
    if ($AcceptLicense -or $Force -or (-not (Test-IsInteractive))) {
        return
    }

    Write-Host "`n$($T.LicenseHeader)" -ForegroundColor Cyan
    Write-Host "  $($T.LicenseSummaryPoint1)" -ForegroundColor Gray
    Write-Host "  $($T.LicenseSummaryPoint2)" -ForegroundColor Gray
    Write-Host "  $($T.LicenseSummaryPoint3)" -ForegroundColor Gray
    Write-Host "  $($T.LicenseSummaryPoint4)" -ForegroundColor Gray
    Write-Host ""

    $accepted = $false
    while (-not $accepted) {
        $choice = Read-Host "$($T.LicensePrompt)"
        if ($choice -match '^[sSyY]$') {
            $accepted = $true
        } elseif ($choice -match '^[vV]$') {
            Write-Host "`n--- [LEGAL / LICENSE] ---" -ForegroundColor DarkCyan
            $licTargetFile = switch ($Lang) {
                "en" { "LICENSE_EN.md" }
                "pt" { "LICENSE_PT.md" }
                default { "LICENSE" }
            }
            try {
                $rawLic = (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$Repo/main/legal/$licTargetFile" -Headers @{"User-Agent"="Goulm-Installer"} -TimeoutSec 5)
                Write-Host $rawLic -ForegroundColor DarkGray
            } catch {
                Write-Host "Ver texto completo en: https://github.com/$Repo/blob/main/legal/$licTargetFile" -ForegroundColor Yellow
            }
            Write-Host "-------------------------`n" -ForegroundColor DarkCyan
        } else {
            Write-Host "`n[!] $($T.LicenseRejected)`n" -ForegroundColor Yellow
            exit 0
        }
    }
}

# -----------------------------------------------------------------------------
# 3. Flujo de Desinstalacion (-Uninstall)
# -----------------------------------------------------------------------------
if ($Uninstall) {
    Show-Banner
    Write-Host "$($T.UninstallHeader)`n" -ForegroundColor Yellow
    Resolve-RunningProcess

    Write-Host "[1/2] $($T.UninstallCleanPath)" -ForegroundColor Gray
    try {
        $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($UserPath -like "*$InstallDir*") {
            $CleanedList = $UserPath -split ';' | Where-Object { $_ -ne $InstallDir -and $_ -ne "" -and (Test-Path $_ -ErrorAction SilentlyContinue) }
            $NewPath = $CleanedList -join ';'
            [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
            Broadcast-EnvironmentChange
        }
    } catch {}

    Write-Host "[2/2] $($T.UninstallRemoveFiles)" -ForegroundColor Gray
    if (Test-Path $InstallDir) {
        Set-Location $env:TEMP
        Remove-Item -Recurse -Force $InstallDir -ErrorAction SilentlyContinue
        Write-Host "`n[OK] $($T.UninstallDone)`n" -ForegroundColor Green
    }
    exit 0
}

# -----------------------------------------------------------------------------
# 4. Flujo de Rollback (-Rollback o Interactivo)
# -----------------------------------------------------------------------------
function Invoke-Rollback {
    if ((Test-Path $BackupExe) -and (Test-Path $BackupVer)) {
        Write-Host "`n>>> $($T.RollbackStart)" -ForegroundColor Cyan
        Resolve-RunningProcess
        $previousTag = (Get-Content $BackupVer -Raw).Trim()

        Copy-Item -Path $BackupExe -Destination $ExeTarget -Force
        Copy-Item -Path $BackupVer -Destination "$InstallDir\.version" -Force
        Remove-Item -Force $BackupExe, $BackupVer -ErrorAction SilentlyContinue

        Write-Host "[OK] $($T.RollbackSuccess -f $previousTag)`n" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "`n[!] $($T.RollbackNotFound)`n" -ForegroundColor Yellow
        exit 1
    }
}

if ($Rollback) {
    Show-Banner
    Invoke-Rollback
}

# -----------------------------------------------------------------------------
# 5. Flujo Principal de Instalacion y Actualizacion
# -----------------------------------------------------------------------------
Show-Banner

# FASE 1: Analisis del Sistema y CPU Nativa
Write-Host "$($T.AnalysisHeader)" -ForegroundColor Yellow

$NativeArchRaw = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
$Arch = if ($NativeArchRaw -eq "ARM64") { "arm64" } else { "amd64" }
Write-Host "  * $($T.ArchDetected -f $Arch)" -ForegroundColor Gray

Resolve-RunningProcess

$CurrentVersion = $null
if (Test-Path "$InstallDir\.version") {
    $CurrentVersion = (Get-Content "$InstallDir\.version" -Raw).Trim()
    Write-Host "  * $($T.LocalInstallFound -f $CurrentVersion)" -ForegroundColor Cyan
} elseif (Test-Path $ExeTarget) {
    try {
        $ver = (Get-Item $ExeTarget).VersionInfo.ProductVersion
        if ($ver) { $CurrentVersion = "v$($ver.Trim())" }
    } catch {}
    if ($CurrentVersion) {
        Write-Host "  * $($T.LocalInstallFound -f $CurrentVersion)" -ForegroundColor Cyan
    }
}

if (-not $CurrentVersion) {
    Write-Host "  * $($T.NoPreviousInstall)" -ForegroundColor Gray
}

# FASE 1.5: Confirmacion de Licencia de Usuario
Assert-LicenseAccepted

# FASE 2: Consulta de Releases con Fallback Resiliente
Write-Host "`n$($T.QueryingRelease)" -ForegroundColor Yellow
Write-Host "  * $($T.ConnectingGitHub -f $Repo)" -ForegroundColor Gray

$LatestTag = $null
$AssetDownloadUrl = $null
$AssetSizeMB = "15"
$Pattern = "goulm-windows-$Arch-*.zip"

$ApiUrl = "https://api.github.com/repos/$Repo/releases/latest"
try {
    $Release = Invoke-RestMethod -Uri $ApiUrl -Headers @{"User-Agent"="Goulm-Installer"} -TimeoutSec 10
    if ($Release -and $Release.tag_name) {
        $LatestTag = $Release.tag_name
        $Asset = $Release.assets | Where-Object { $_.name -like $Pattern } | Select-Object -First 1
        if ($Asset) {
            $AssetDownloadUrl = $Asset.browser_download_url
            $AssetSizeMB = [math]::Round(($Asset.size / 1MB), 2)
            Write-Host "  * $($T.LatestVersionFound -f $LatestTag)" -ForegroundColor Green
            Write-Host "  * $($T.AssetSpecs -f $Asset.name, $AssetSizeMB)" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "  * $($T.ApiRateLimitFallback)" -ForegroundColor Yellow
    $LatestTag = "latest"
    $AssetDownloadUrl = "https://github.com/$Repo/releases/latest/download/goulm-windows-$Arch.zip"
}

if (-not $AssetDownloadUrl) {
    $AssetDownloadUrl = "https://github.com/$Repo/releases/latest/download/goulm-windows-$Arch.zip"
}

# Verificacion si ya esta al dia
if ($CurrentVersion -and ($CurrentVersion -eq $LatestTag) -and (-not $Force)) {
    Write-Host "`n[OK] $($T.AlreadyUpToDate -f $LatestTag)" -ForegroundColor Green
    
    if ((Test-Path $BackupExe) -and (Test-Path $BackupVer) -and (Test-IsInteractive)) {
        $bVer = (Get-Content $BackupVer -Raw).Trim()
        $doRollback = Read-Host "$($T.AskRollback -f $bVer)"
        if ($doRollback -match '^[sSyY]$') {
            Invoke-Rollback
        }
    }

    if (Test-IsInteractive) {
        $reinstall = Read-Host "$($T.AskReinstall)"
        if ($reinstall -notmatch '^[sSyY]$') {
            Write-Host "Operacion finalizada sin cambios.`n" -ForegroundColor Gray
            exit 0
        }
    }
}

# FASE 3: Descarga Segura, Verificacion de Integridad y Respaldo
Write-Host "`n$($T.InstallPlan)" -ForegroundColor Yellow

# 1. Crear respaldo si ya existia un binario
if (Test-Path $ExeTarget) {
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    }
    Copy-Item -Path $ExeTarget -Destination $BackupExe -Force
    if ($CurrentVersion) {
        Set-Content -Path $BackupVer -Value $CurrentVersion -Force
    }
    Write-Host "  * Respaldo previo resguardado localmente ($CurrentVersion)" -ForegroundColor DarkGray
}

# 2. Descarga con verificacion de integridad
$TempZip = "$env:TEMP\goulm_download_$Arch.zip"
Write-Host "  * $($T.DownloadTarget) (~$($AssetSizeMB) MB)..." -ForegroundColor Cyan

Write-Host "    ------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "    INFO: $($T.Tip1)" -ForegroundColor DarkYellow
Write-Host "    INFO: $($T.Tip2)" -ForegroundColor DarkYellow
Write-Host "    ------------------------------------------------------------------" -ForegroundColor DarkGray

$downloadSuccess = $false
for ($attempt = 1; $attempt -le 2; $attempt++) {
    try {
        Remove-Item -Force $TempZip -ErrorAction SilentlyContinue
        Invoke-WebRequest -Uri $AssetDownloadUrl -OutFile $TempZip -UseBasicParsing -TimeoutSec 45
        if (Test-ZipIntegrity $TempZip) {
            $downloadSuccess = $true
            break
        } else {
            Write-Host "    [!] $($T.ZipCorrupted)" -ForegroundColor Yellow
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}

if (-not $downloadSuccess) {
    Write-Host "`n[x] $($T.ZipFailedCompletely)" -ForegroundColor Red
    Show-EscapeRoute $AssetDownloadUrl
    exit 1
}

# 3. Descompresion y extraccion limpia
Write-Host "  * $($T.ExtractingTarget)" -ForegroundColor Cyan
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
}

try {
    Expand-Archive -Path $TempZip -DestinationPath $InstallDir -Force
} catch {
    Write-Host "`n[!] $($T.AntivirusWarning)" -ForegroundColor Red
    Write-Host "    $($T.AntivirusHelp -f $ExeTarget)" -ForegroundColor Yellow
    Show-EscapeRoute $AssetDownloadUrl
    exit 1
} finally {
    Remove-Item -Force $TempZip -ErrorAction SilentlyContinue
}

try {
    Get-ChildItem -Path $InstallDir -Recurse | Unblock-File -ErrorAction SilentlyContinue
} catch {}

Set-Content -Path "$InstallDir\.version" -Value $LatestTag -Force

# 4. Generar desinstalador local y portable
$LocalUninstaller = @"
# Goulm CLI Local Uninstaller
`$InstallDir = "$InstallDir"
Write-Host "Desinstalando Goulm..." -ForegroundColor Yellow
`$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (`$UserPath -like "*`$InstallDir*") {
    `$NewPath = (`$UserPath -split ';' | Where-Object { `$_ -ne `$InstallDir -and `$_ -ne "" }) -join ';'
    [Environment]::SetEnvironmentVariable("Path", `$NewPath, "User")
}
Set-Location `$env:TEMP
Remove-Item -Recurse -Force `$InstallDir
Write-Host "Goulm desinstalado correctamente." -ForegroundColor Green
"@
Set-Content -Path "$InstallDir\uninstall.ps1" -Value $LocalUninstaller -Force

# 5. Configuracion del PATH de Usuario y Saneamiento
Write-Host "  * $($T.UpdatingPath)" -ForegroundColor Cyan
try {
    $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($UserPath -split ';' -notcontains $InstallDir) {
        $PathClean = ($UserPath -split ';' | Where-Object { $_ -ne "" }) -join ';'
        $NewPath = if ([string]::IsNullOrEmpty($PathClean)) { $InstallDir } else { "$PathClean;$InstallDir" }
        [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    }
    if ($env:Path -split ';' -notcontains $InstallDir) {
        $env:Path += ";$InstallDir"
    }
} catch {}

Write-Host "  * $($T.Broadcasting)" -ForegroundColor Gray
Broadcast-EnvironmentChange

# -----------------------------------------------------------------------------
# 6. Pantalla Final de Confirmacion, Componentes y Donaciones
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "$($T.FinalHeader)" -ForegroundColor Green
Write-Host " [✓] $($T.SuccessTitle)" -ForegroundColor Green
Write-Host "$($T.FinalHeader)" -ForegroundColor Green
Write-Host "  $($T.InstalledVersion -f $LatestTag)" -ForegroundColor White
Write-Host "  $($T.InstallPath -f $InstallDir)" -ForegroundColor White
Write-Host ""
Write-Host " $($T.TreeHeader)" -ForegroundColor Cyan
Write-Host "   $($T.TreeExe)" -ForegroundColor White
Write-Host "   $($T.TreeReadme)" -ForegroundColor Gray
Write-Host "   $($T.TreeLegal)" -ForegroundColor Gray
Write-Host "   $($T.TreeNotices)" -ForegroundColor Gray
Write-Host "   $($T.TreeDonate)" -ForegroundColor Gray
Write-Host "   $($T.TreeUninst)" -ForegroundColor Gray
Write-Host ""
Write-Host " $($T.DonateHeader)" -ForegroundColor Yellow
Write-Host "   $($T.DonateKofi)" -ForegroundColor Cyan
Write-Host ""
Write-Host " $($T.TipsHeader)" -ForegroundColor Yellow
Write-Host "   💡 $($T.Tip1)" -ForegroundColor Gray
Write-Host "   💡 $($T.Tip2)" -ForegroundColor Gray
Write-Host "   💡 $($T.Tip3)" -ForegroundColor Gray
Write-Host "   💡 $($T.Tip4)" -ForegroundColor Gray
Write-Host ""
Write-Host " $($T.NextSteps)" -ForegroundColor Cyan
Write-Host "   $($T.Step1)" -ForegroundColor White
Write-Host "   $($T.Step2)" -ForegroundColor White
Write-Host "$($T.FinalHeader)" -ForegroundColor Green
Write-Host ""
