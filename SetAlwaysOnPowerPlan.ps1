# Get Current Active Plan
$OriginalPlan = $(powercfg -getactivescheme).split()[3]
# Duplicate Current Active Plan
$Duplicate = powercfg -duplicatescheme $OriginalPlan
# Change Name of Duplicated Plan
$CurrentPlan = powercfg -changename ($Duplicate).split()[3] "TTS Always On Power Plan"
# Set New Plan as Active Plan
$SetActiveNewPlan = powercfg -setactive ($Duplicate).split()[3]
# Get the New Plan
$NewPlan = $(powercfg -getactivescheme).split()[3]

$PowerGUID = '4f971e89-eebd-4455-a8de-9e59040e7347'
$PowerButtonGUID = '7648efa3-dd9c-4e3e-b566-50f929386280'
$LidClosedGUID = '5ca83367-6e45-459f-a27b-476b1d01c936'
$SleepGUID = '238c9fa8-0aad-41ed-83f4-97be242c8f20'


#POWER BUTTON

# PowerButton - On Battery - 3 = shutdown
cmd /c "powercfg /setdcvalueindex $NewPlan $PowerGUID $PowerButtonGUID 3"
# PowerButton - While plugged in - 3 = Shutdown
cmd /c "powercfg /setacvalueindex $NewPlan $PowerGUID $PowerButtonGUID 3"


#SLEEP BUTTON

# SleepButton - On Battery - 0 = Do Nothing
cmd /c "powercfg /setdcvalueindex $NewPlan $PowerGUID $SleepGUID 0"
# SleepButton - While plugged in - 0 = Do Nothing
cmd /c "powercfg /setacvalueindex $NewPlan $PowerGUID $SleepGUID 0"


#LID CLOSED

# Lid Closed - On Battery - 1 = Sleep
cmd /c "powercfg /setdcvalueindex $NewPlan $PowerGUID $LidClosedGUID 1"
# Lid Closed - While plugged in - 0 = Do Nothing
cmd /c "powercfg /setacvalueindex $NewPlan $PowerGUID $LidClosedGUID 0"


# PLAN SETTINGS

#Turn off Display - On Battery - 15 = 15 Minutes
powercfg -change -monitor-timeout-dc 15
#Turn off Display - While plugged in - 0 = Never
powercfg -change -monitor-timeout-ac 0
#Sleep Mode - On Battery - 0 = Never
powercfg -change -standby-timeout-ac 0
#Sleep Mode - While plugged in - 0 = Never
powercfg -change -standby-timeout-dc 0


#APPLY CHANGES
cmd /c "powercfg /s $NewPlan"