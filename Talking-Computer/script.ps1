param( [string]$comment = $_ )
Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer

#Options you can tweak below: Female-Male-Neutral
# There are also 'age' settings in the .NET documentation that I haven't dug into yet.
$speak.SelectVoiceByHints('Female')
$speak.Speak("$comment")