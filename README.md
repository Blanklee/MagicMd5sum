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

- ver 1.5 / 2021.03.29
  - Show total size when file added


<br/>

# ScreenShot :

![1_Initial](https://user-images.githubusercontent.com/26485313/112787569-c2ef7f80-9093-11eb-8157-20ffb5159488.png)

![4_AddFile](https://user-images.githubusercontent.com/26485313/112787581-cbe05100-9093-11eb-957d-a883dc911b34.png)

![4a_AddFile](https://user-images.githubusercontent.com/26485313/112787585-ce42ab00-9093-11eb-8e45-b64210606a60.png)

![5_Run](https://user-images.githubusercontent.com/26485313/112787597-d39ff580-9093-11eb-820d-ff1369f09f5f.png)

![5a_Run](https://user-images.githubusercontent.com/26485313/112787606-d864a980-9093-11eb-999f-845b827aa593.png)

![5c_Finish](https://user-images.githubusercontent.com/26485313/112787608-da2e6d00-9093-11eb-84f1-97c9ab83911a.png)

<br/><br/>
