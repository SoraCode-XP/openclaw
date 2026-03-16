# OpenClaw Multi-Agent Setup Script
# Automated installation for three-agent system

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "OpenClaw Multi-Agent Setup" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$SetupDir = "E:\Project\openclaw\openclaw-multi-agent-setup"
$OpenClawDir = "$env:USERPROFILE\.openclaw"
$DocumentsDir = "$env:USERPROFILE\Documents"

# Step 1: Backup existing config
Write-Host "[1/7] Backup existing config..." -ForegroundColor Yellow
if (Test-Path "$OpenClawDir\openclaw.json") {
    $BackupFile = "$OpenClawDir\openclaw.json.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item "$OpenClawDir\openclaw.json" $BackupFile
    Write-Host "  OK Backed up to: $BackupFile" -ForegroundColor Green
} else {
    Write-Host "  INFO No existing config found" -ForegroundColor Gray
}

# Step 2: Copy config file
Write-Host "[2/7] Copy agent config..." -ForegroundColor Yellow
Copy-Item "$SetupDir\openclaw.json" "$OpenClawDir\openclaw.json" -Force
Write-Host "  OK openclaw.json copied" -ForegroundColor Green

# Step 3: Copy workspaces
Write-Host "[3/7] Copy workspace files..." -ForegroundColor Yellow

if (Test-Path "$OpenClawDir\workspace-main") {
    Remove-Item "$OpenClawDir\workspace-main" -Recurse -Force
}
Copy-Item "$SetupDir\workspace-main" "$OpenClawDir\workspace-main" -Recurse -Force
Write-Host "  OK Main workspace copied" -ForegroundColor Green

if (Test-Path "$OpenClawDir\workspace-recruiter") {
    Remove-Item "$OpenClawDir\workspace-recruiter" -Recurse -Force
}
Copy-Item "$SetupDir\workspace-recruiter" "$OpenClawDir\workspace-recruiter" -Recurse -Force
Write-Host "  OK Recruiter workspace copied" -ForegroundColor Green

if (Test-Path "$OpenClawDir\workspace-person-info") {
    Remove-Item "$OpenClawDir\workspace-person-info" -Recurse -Force
}
Copy-Item "$SetupDir\workspace-person-info" "$OpenClawDir\workspace-person-info" -Recurse -Force
Write-Host "  OK Person-Info workspace copied" -ForegroundColor Green

# Step 4: Create directories
Write-Host "[4/7] Create directories..." -ForegroundColor Yellow

New-Item -Path "$OpenClawDir\workspace-person-info\persons" -ItemType Directory -Force | Out-Null
Write-Host "  OK persons/ directory created" -ForegroundColor Green

New-Item -Path "$DocumentsDir\openclaw-templates" -ItemType Directory -Force | Out-Null
Write-Host "  OK openclaw-templates/ created" -ForegroundColor Green

New-Item -Path "$DocumentsDir\openclaw-filled" -ItemType Directory -Force | Out-Null
Write-Host "  OK openclaw-filled/ created" -ForegroundColor Green

# Step 5: Check Python
Write-Host "[5/7] Check Python..." -ForegroundColor Yellow
try {
    $PythonVersion = python --version 2>&1
    Write-Host "  OK Python installed: $PythonVersion" -ForegroundColor Green
    
    $DocxCheck = python -c "import docx; print('OK')" 2>&1
    if ($DocxCheck -eq "OK") {
        Write-Host "  OK python-docx installed" -ForegroundColor Green
    } else {
        Write-Host "  WARN Installing python-docx..." -ForegroundColor Yellow
        pip install python-docx | Out-Null
        Write-Host "  OK python-docx installed" -ForegroundColor Green
    }
} catch {
    Write-Host "  ERROR Python not found in PATH" -ForegroundColor Red
    Write-Host "    Download from https://www.python.org/downloads/" -ForegroundColor Red
}

# Step 6: Validate config
Write-Host "[6/7] Validate OpenClaw config..." -ForegroundColor Yellow
try {
    $ValidateResult = openclaw config validate 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK Config validation passed" -ForegroundColor Green
    } else {
        Write-Host "  ERROR Config validation failed:" -ForegroundColor Red
        Write-Host "    $ValidateResult" -ForegroundColor Red
    }
} catch {
    Write-Host "  WARN Cannot validate (OpenClaw CLI not found)" -ForegroundColor Yellow
}

# Step 7: Done
Write-Host "[7/7] Installation complete" -ForegroundColor Yellow
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Restart gateway:" -ForegroundColor White
Write-Host "     openclaw gateway restart" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. List agents:" -ForegroundColor White
Write-Host "     openclaw agents list --bindings" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Test (send to Main agent):" -ForegroundColor White
Write-Host "     - Ask about agents" -ForegroundColor Gray
Write-Host "     - Create new agent" -ForegroundColor Gray
Write-Host "     - Collect info" -ForegroundColor Gray
Write-Host ""
Write-Host "For details, see README.md" -ForegroundColor White
Write-Host ""
Write-Host "文档位置：" -ForegroundColor White
Write-Host "  - 配置文件: $OpenClawDir\openclaw.json" -ForegroundColor Gray
Write-Host "  - 工作空间: $OpenClawDir\workspace-*" -ForegroundColor Gray
Write-Host "  - 模板目录: $DocumentsDir\openclaw-templates" -ForegroundColor Gray
Write-Host "  - 输出目录: $DocumentsDir\openclaw-filled" -ForegroundColor Gray
Write-Host ""
Write-Host "如遇问题，请查看 README.md 获取详细说明。" -ForegroundColor White
