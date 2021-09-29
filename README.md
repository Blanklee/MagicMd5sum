# MagicMd5sum

- Overview : Windows Graphic UI Program of md5sum, Easy to use.

- Develop Tools : Delphi 11 using Indy component.

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

- ver 1.4a / 2021.02.14 \
  . Delete 'RUN (v1.3)' button, rename 'RUN (v1.4)' to 'RUN!' \
  . Add icon to project (icon3.ico)

- ver 1.4b / 2021.03.05 \
  . btRun, btPause, btStop is replaced from TButton to TBitBtn, add Glyph \
  . Show elapsed time after finishing md5sum calculation

- ver 1.5 / 2021.03.29 \
  . Show total size when file added

- ver 1.5a / 2021.04.11 \
  . Apply 'Sky' style, design changed

- ver 1.6 / 2021.05.20 \
  . Support adding directory : all files in the directory are added

- ver 1.7 / 2021.09.18 \
  . Open button added : on WinPE we can also add files by Open dialog \
  . Add shortcut key at each buttons \
  . Disable Open, Clear button while Running calculation

- ver 1.8 / 2021.09.26 \
  . Implement thread based calculation \
  . Sort file list when click Run button \
  . Improve more fast

- ver 1.8a / 2021.09.29 \
  . Manage FileList auto sorted and unique \
  . Implement Pause button


<br/>

# ScreenShots :

![1_Main](https://user-images.githubusercontent.com/26485313/135238418-f7e55780-9dad-4ce0-8c6a-0e9ad2c3ff5d.png)

![2_Run1](https://user-images.githubusercontent.com/26485313/135238425-66c6046b-681a-4ca5-8332-6e2350a1576b.png)

![3_Finish](https://user-images.githubusercontent.com/26485313/135238428-d2984b86-e20a-4eed-9045-0da7e18ec2b1.png)

<br/><br/>

