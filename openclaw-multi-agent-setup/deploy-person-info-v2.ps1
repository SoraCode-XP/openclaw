# Person-Info v2.0 Deployment Script
# Deploys智能文档处理功能到 OpenClaw 工作空间

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Person-Info v2.0 Deployment" -ForegroundColor Cyan
Write-Host "Smart Document Processing" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$SetupDir = "E:\Project\openclaw\openclaw-multi-agent-setup"
$WorkspaceDir = "$env:USERPROFILE\.openclaw\workspace-person-info"

# Backup existing files
Write-Host "[1/5] Backup existing files..." -ForegroundColor Yellow
if (Test-Path "$WorkspaceDir\AGENTS.md") {
    $BackupFile = "$WorkspaceDir\AGENTS.md.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item "$WorkspaceDir\AGENTS.md" $BackupFile
    Write-Host "  OK Backed up to: $BackupFile" -ForegroundColor Green
} else {
    Write-Host "  INFO No existing AGENTS.md" -ForegroundColor Gray
}

# Deploy new AGENTS.md
Write-Host "[2/5] Deploy new AGENTS.md..." -ForegroundColor Yellow
Copy-Item "$SetupDir\workspace-person-info\AGENTS-v2.md" "$WorkspaceDir\AGENTS.md" -Force
Write-Host "  OK AGENTS.md updated" -ForegroundColor Green

# Create new skill directory
Write-Host "[3/5] Create doc-template-generator skill..." -ForegroundColor Yellow
$SkillDir = "$WorkspaceDir\skills\doc-template-generator"
$ScriptsDir = "$SkillDir\scripts"

New-Item -Path $SkillDir -ItemType Directory -Force | Out-Null
New-Item -Path $ScriptsDir -ItemType Directory -Force | Out-Null

Copy-Item "$SetupDir\workspace-person-info\skills\doc-template-generator\SKILL.md" "$SkillDir\SKILL.md" -Force
Copy-Item "$SetupDir\workspace-person-info\skills\doc-template-generator\scripts\template_generator.py" "$ScriptsDir\template_generator.py" -Force
Copy-Item "$SetupDir\workspace-person-info\skills\doc-template-generator\scripts\requirements.txt" "$ScriptsDir\requirements.txt" -Force

Write-Host "  OK doc-template-generator skill installed" -ForegroundColor Green

# Create necessary directories
Write-Host "[4/5] Create workspace directories..." -ForegroundColor Yellow

$Dirs = @(
    "$WorkspaceDir\uploads",
    "$WorkspaceDir\temp",
    "$WorkspaceDir\templates",
    "$WorkspaceDir\output"
)

foreach ($dir in $Dirs) {
    New-Item -Path $dir -ItemType Directory -Force | Out-Null
    $dirName = Split-Path $dir -Leaf
    Write-Host "  OK $dirName/ created" -ForegroundColor Green
}

# Install Python dependencies
Write-Host "[5/5] Check Python dependencies..." -ForegroundColor Yellow
try {
    $PythonVersion = python --version 2>&1
    Write-Host "  OK Python: $PythonVersion" -ForegroundColor Green
    
    $modules = @("docx")
    $allInstalled = $true
    
    foreach ($module in $modules) {
        $checkCmd = "python -c `"import $module; print('OK')`" 2>&1"
        $result = Invoke-Expression $checkCmd
        if ($result -eq "OK") {
            Write-Host "  OK python-$module installed" -ForegroundColor Green
        } else {
            $allInstalled = $false
        }
    }
    
    if (-not $allInstalled) {
        Write-Host "  WARN Installing python-docx..." -ForegroundColor Yellow
        pip install -r "$ScriptsDir\requirements.txt" | Out-Null
        Write-Host "  OK python-docx installed" -ForegroundColor Green
    }
    
} catch {
    Write-Host "  ERROR Python not found" -ForegroundColor Red
    Write-Host "    Please install Python 3.7+ from https://www.python.org/" -ForegroundColor Red
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "New Features:" -ForegroundColor White
Write-Host "  - Smart document analysis with AI" -ForegroundColor Gray
Write-Host "  - Auto field identification" -ForegroundColor Gray
Write-Host "  - Template generation from any Word doc" -ForegroundColor Gray
Write-Host "  - One-click document filling" -ForegroundColor Gray
Write-Host ""
Write-Host "Workspace Structure:" -ForegroundColor White
Write-Host "  uploads/     - Upload original documents here" -ForegroundColor Gray
Write-Host "  temp/        - Temporary analysis files" -ForegroundColor Gray
Write-Host "  templates/   - Generated templates" -ForegroundColor Gray
Write-Host "  output/      - Filled documents" -ForegroundColor Gray
Write-Host "  persons/     - Personal information (JSON)" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor White
Write-Host "  1. Restart gateway:" -ForegroundColor White
Write-Host "     cd E:\Project\openclaw" -ForegroundColor Gray
Write-Host "     pnpm openclaw gateway restart" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Test by sending message:" -ForegroundColor White
Write-Host "     'Upload a Word document for smart processing'" -ForegroundColor Gray
Write-Host ""
