---
title: 多个EXCEL文件合并成一个EXCEL
date: 2017-06-08
tags:
- EXCEL
categories:
 - Database
---


经常会接到导码需求，附件有txt的也有excel的，动辄上百个文件

如果是文本可以用`cat xxx.txt >> yyy.txt`来合并

那如果是excel就不好办了，今天就遇到了

要把上百个EXCEL文件合并成新一个文件

合并方法如下：

1.需要把多个excel表都放在同一个文件夹里面，并在这个文件夹里面新建一个excel。

2.打开新建的excel表，并右键单击sheet1，找到`查看代码`，单击进去。进去之后就看到了宏计算界面。

3.然后把下面这些宏计算的代码复制进去，然后找到工具栏上面的`运行`下的`运行子过程/用户窗体`，代码如下:

```bash
Sub 合并当前目录下所有工作簿的全部工作表()

Dim MyPath, MyName, AWbName
Dim Wb As Workbook, WbN As String

Dim G As Long

Dim Num As Long

Dim BOX As String

Application.ScreenUpdating = False

MyPath = ActiveWorkbook.Path

MyName = Dir(MyPath & "\" & "*.xls")

AWbName = ActiveWorkbook.Name

Num = 0

Do While MyName <> ""

If MyName <> AWbName Then

Set Wb = Workbooks.Open(MyPath & "\" & MyName)

Num = Num + 1

With Workbooks(1).ActiveSheet

.Cells(.Range("B65536").End(xlUp).Row + 2, 1) = Left(MyName, Len(MyName) - 4)

For G = 1 To Sheets.Count

Wb.Sheets(G).UsedRange.Copy .Cells(.Range("B65536").End(xlUp).Row + 1, 1)

Next

WbN = WbN & Chr(13) & Wb.Name

Wb.Close False

End With

End If

MyName = Dir

Loop

Range("B1").Select

Application.ScreenUpdating = True

MsgBox "共合并了" & Num & "个工作薄下的全部工作表。如下：" & Chr(13) & WbN, vbInformation, "提示"

End Sub
```

4.点击运行之后，等待合并（合并文件越多耗时越久），等运行完毕，会有提示，点确定就可以了；查看合并后的数据。

>* ps: 被合并excel版本必须相同，上面代码是合并后缀为`xls`的excel, 如果是Excel2007那就要改为`xlsx`

转载自：

https://zhidao.baidu.com/question/96195372.html


