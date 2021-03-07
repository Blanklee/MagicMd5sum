# MagicMd5sum

- Overview : Windows Graphic UI Program of md5sum, Easy to use.

- Develop Tools : Delphi 10.4.1 using Indy component.

- Usage : Just drop files and click RUN button.

<br/>

# Release Notes :

- ver 1.0 / 2020.10.16 \
  . Start up Windows GUI version of MD5SUM \
  . Just drop files and click RUN button \
  . Implement essential core functions, very basically

- ver 1.1 / 2020.10.19 / Drop \
  . Try to show progress bar (failed)

- ver 1.2 / 2020.10.21 \
  . Add 'Copy Text' button : copy Memo1.Text to ClipBoard \
  . Implement Ctrl-A, Ctrl-C on Memo1 : same action as 'Copy Text' button \
  . User can conveniently copy Memo1.Text to Clipboard \
  . Add 'Clear' button : clear all text on Memo1

- ver 1.3 / 2020.11.04 \
  . Support continuous drop \
  . If files are dropped several times, it is managed accumulatively in FileList \
  . Before, only the last dropped list was processed

- ver 1.4 / 2020.11.18
  - Implement much faster speed \
    . with 3.5GB it takes 02:05 at v1.3, 00:11 at v1.4 (8~10 times faster) \
	. internally use MyHash5, it fetches 512KB at once on calculation
  - Show ProgressBar during run \
    . Derive TProgressBar to implement Int64 for large files bigger than 2GB \
    . To show rate it gets total bytes from File_Size function (BlankUtils.pas)
  - Support Pause & Stop button

- ver 1.4a / 2021.02.14
  - Delete 'RUN (v1.3)' button, rename 'RUN (v1.4)' to 'RUN!'
  - Add icon to project (icon3.ico)

- ver 1.4b / 2021.03.05
  - btRun, btPause, btStop is replaced from TButton to TBitBtn, add Glyph
  - Show elapsed time after finishing md5sum calculation


<br/>

# ScreenShot :

![1_Initial](https://user-images.githubusercontent.com/26485313/110225170-05ef8480-7f26-11eb-9020-1aa2329815c7.png)

![3c_Running](https://user-images.githubusercontent.com/26485313/110225171-08ea7500-7f26-11eb-9156-ce7f892f88b4.png)

![4_Finish](https://user-images.githubusercontent.com/26485313/110225172-0ab43880-7f26-11eb-9e8e-3c95a54e8b1b.png)

<br/><br/>
