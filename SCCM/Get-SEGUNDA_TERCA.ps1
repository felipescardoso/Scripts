#Script para verificacao dos patches do mes anterior a execucao do script
$dataHoje = Get-Date -Format "dd-MM-yyyy"
#Verificacao do mes atual
$mes = (Get-Date).Month
$ano = (Get-Date).Year
$dia = 1

(Get-date -Format "dd/MM/yyyy" -Day $dia -Month $mes -Year $ano)
#Grava e exibe o dia da semana
$DiaSemana = (Get-date -Day 01 -Month $mes -Year $ano).DayOfWeek
Write-Host "$DiaSemana"
#Verifica se o dia é terça. Caso não seja, incrementa até ser
While ($DiaSemana -ne "Tuesday") {
    $dia++
    $DiaSemana = ((Get-date -Day $dia -Month $mes -Year $ano)).DayOfWeek
    Write-Host $DiaSemana
}
$segundaTerPrimQuinta = (Get-date -Day $dia -Month $mes -Year $ano -Hour 00 -Minute 00 -Second 00).AddDays(7)
Write-Host $segundaTerPrimQuinta


