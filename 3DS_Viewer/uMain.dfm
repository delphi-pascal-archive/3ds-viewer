object fm3DView: Tfm3DView
  Left = 220
  Top = 124
  Width = 920
  Height = 643
  Caption = '3DS Viewer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyUp = FormKeyUp
  OnMouseWheel = FormMouseWheel
  DesignSize = (
    912
    595)
  PixelsPerInch = 120
  TextHeight = 16
  object pnDraw: TPanel
    Left = 0
    Top = 0
    Width = 661
    Height = 720
    Cursor = crCross
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsSingle
    TabOrder = 0
    OnMouseDown = pnDrawMouseDown
    OnMouseMove = pnDrawMouseMove
    OnMouseUp = pnDrawMouseUp
  end
  object tcTabs: TTabControl
    Left = 670
    Top = 0
    Width = 444
    Height = 720
    Anchors = [akTop, akRight, akBottom]
    MultiLine = True
    TabOrder = 1
    TabPosition = tpRight
    Tabs.Strings = (
      '---- View -----'
      '------ Info  -----'
      '---- Lighting ---'
      '---- Errors ---')
    TabIndex = 0
    OnChange = tcTabsChange
    DesignSize = (
      444
      720)
    object gbLight: TGroupBox
      Left = -1
      Top = 0
      Width = 406
      Height = 720
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = ' Light '
      TabOrder = 0
      Visible = False
      object gbLightPos: TGroupBox
        Left = 10
        Top = 473
        Width = 346
        Height = 141
        Caption = #1056#1086#1079#1090#1072#1096#1091#1074#1072#1085#1085#1103' '#1076#1078#1077#1088#1077#1083#1072' '#1089#1074#1110#1090#1083#1072
        TabOrder = 2
      end
      object gbLgtSpec: TGroupBox
        Left = 10
        Top = 30
        Width = 346
        Height = 141
        Caption = 'Specular color'
        TabOrder = 0
        object lblR1: TLabel
          Left = 20
          Top = 20
          Width = 24
          Height = 23
          Caption = 'R:'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clRed
          Font.Height = -20
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label2: TLabel
          Left = 20
          Top = 59
          Width = 24
          Height = 23
          Caption = 'G:'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clGreen
          Font.Height = -20
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label3: TLabel
          Left = 20
          Top = 98
          Width = 24
          Height = 23
          Caption = 'B:'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clBlue
          Font.Height = -20
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object tbRLS: TTrackBar
          Left = 49
          Top = 20
          Width = 287
          Height = 40
          Max = 64
          TabOrder = 0
          OnChange = tbRLSChange
        end
        object tbGLS: TTrackBar
          Left = 49
          Top = 59
          Width = 287
          Height = 41
          Max = 64
          TabOrder = 1
          OnChange = tbGLSChange
        end
        object tbBLS: TTrackBar
          Left = 49
          Top = 98
          Width = 287
          Height = 41
          Max = 64
          TabOrder = 2
          OnChange = tbBLSChange
        end
      end
      object gbLgtAmb: TGroupBox
        Left = 10
        Top = 177
        Width = 346
        Height = 142
        Caption = 'Ambient color'
        TabOrder = 1
        object Label4: TLabel
          Left = 20
          Top = 20
          Width = 24
          Height = 23
          Caption = 'R:'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clRed
          Font.Height = -20
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label5: TLabel
          Left = 20
          Top = 59
          Width = 24
          Height = 23
          Caption = 'G:'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clGreen
          Font.Height = -20
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label6: TLabel
          Left = 20
          Top = 98
          Width = 24
          Height = 23
          Caption = 'B:'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clBlue
          Font.Height = -20
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object tbRLA: TTrackBar
          Left = 49
          Top = 20
          Width = 287
          Height = 40
          Max = 64
          TabOrder = 0
          OnChange = tbRLAChange
        end
        object tbGLA: TTrackBar
          Left = 49
          Top = 59
          Width = 287
          Height = 41
          Max = 64
          TabOrder = 1
          OnChange = tbGLAChange
        end
        object tbBLA: TTrackBar
          Left = 49
          Top = 98
          Width = 287
          Height = 41
          Max = 64
          TabOrder = 2
          OnChange = tbBLAChange
        end
      end
      object gbLgtDif: TGroupBox
        Left = 10
        Top = 325
        Width = 346
        Height = 141
        Caption = 'Diffuse color'
        TabOrder = 3
        object Label1: TLabel
          Left = 20
          Top = 20
          Width = 24
          Height = 23
          Caption = 'R:'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clRed
          Font.Height = -20
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label7: TLabel
          Left = 20
          Top = 59
          Width = 24
          Height = 23
          Caption = 'G:'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clGreen
          Font.Height = -20
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label8: TLabel
          Left = 20
          Top = 98
          Width = 24
          Height = 23
          Caption = 'B:'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clBlue
          Font.Height = -20
          Font.Name = 'Courier New'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object tbRLD: TTrackBar
          Left = 49
          Top = 20
          Width = 287
          Height = 40
          Max = 64
          TabOrder = 0
          OnChange = tbRLDChange
        end
        object tbGLD: TTrackBar
          Left = 49
          Top = 59
          Width = 287
          Height = 41
          Max = 64
          TabOrder = 1
          OnChange = tbGLDChange
        end
        object tbBLD: TTrackBar
          Left = 49
          Top = 98
          Width = 287
          Height = 41
          Max = 64
          TabOrder = 2
          OnChange = tbBLDChange
        end
      end
    end
    object gbErrors: TGroupBox
      Left = 0
      Top = 0
      Width = 395
      Height = 710
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = ' Errors '
      TabOrder = 2
      DesignSize = (
        395
        710)
      object mmError: TMemo
        Left = 10
        Top = 20
        Width = 375
        Height = 670
        Anchors = [akLeft, akTop, akRight, akBottom]
        Lines.Strings = (
          'mmError')
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object gbView: TGroupBox
      Left = 0
      Top = 0
      Width = 405
      Height = 710
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = ' View '
      TabOrder = 3
      DesignSize = (
        405
        710)
      object lblModelBox: TLabel
        Left = 20
        Top = 69
        Width = 59
        Height = 16
        Caption = 'No model'
      end
      object lblFPS: TLabel
        Left = 20
        Top = 39
        Width = 24
        Height = 16
        Caption = 'fps: '
      end
      object ledScale: TLabeledEdit
        Left = 197
        Top = 30
        Width = 178
        Height = 25
        BorderStyle = bsNone
        EditLabel.Width = 50
        EditLabel.Height = 16
        EditLabel.Caption = ' Scale    '
        LabelPosition = lpLeft
        TabOrder = 0
        OnExit = ledScaleExit
        OnKeyPress = ledScaleKeyPress
      end
      object trvObjects: TTreeView
        Left = 10
        Top = 305
        Width = 385
        Height = 395
        Anchors = [akLeft, akTop, akRight, akBottom]
        Indent = 19
        MultiSelect = True
        MultiSelectStyle = [msControlSelect, msShiftSelect]
        PopupMenu = ppmnObjView
        RightClickSelect = True
        TabOrder = 1
      end
    end
    object gbInfo: TGroupBox
      Left = 0
      Top = 0
      Width = 395
      Height = 700
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = ' Model '
      TabOrder = 1
      DesignSize = (
        395
        700)
      object cmbObjects: TComboBox
        Left = 8
        Top = 24
        Width = 225
        Height = 24
        Anchors = [akTop, akRight]
        ItemHeight = 16
        TabOrder = 0
        Text = 'objects'
        OnChange = cmbObjectsChange
      end
      object cmbMaterials: TComboBox
        Left = 8
        Top = 56
        Width = 225
        Height = 24
        Anchors = [akTop, akRight]
        ItemHeight = 16
        TabOrder = 1
        Text = 'materials'
        OnChange = cmbMaterialsChange
      end
      object mmInfo: TMemo
        Left = 8
        Top = 88
        Width = 225
        Height = 497
        Anchors = [akLeft, akTop, akRight, akBottom]
        ScrollBars = ssVertical
        TabOrder = 2
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 56
    Top = 16
    object mnFile: TMenuItem
      Caption = '&File'
      object mnFOpen: TMenuItem
        Caption = 'Open'
        ShortCut = 114
        OnClick = mnFOpenClick
      end
      object mnFClose: TMenuItem
        Caption = 'Close'
        ShortCut = 32882
        OnClick = mnFCloseClick
      end
      object mnFSep: TMenuItem
        Caption = '-'
      end
      object mnFRecent: TMenuItem
        Caption = 'Recent'
        Enabled = False
      end
      object mnFSep2: TMenuItem
        Caption = '-'
      end
      object mnFExit: TMenuItem
        Caption = 'Exit'
        OnClick = mnFExitClick
      end
      object mnFDefOpen: TMenuItem
        Caption = 'def_open'
        ShortCut = 16498
        Visible = False
        OnClick = mnFDefOpenClick
      end
    end
    object mnView: TMenuItem
      Caption = '&View'
      object mnVAxis: TMenuItem
        Caption = 'Show axes'
        Checked = True
        ShortCut = 122
        OnClick = mnVAxisClick
      end
      object mnVAutosize: TMenuItem
        Caption = 'Autosize'
        Checked = True
        ShortCut = 121
        OnClick = mnVAutosizeClick
      end
      object mnVShowGround: TMenuItem
        Caption = 'Show ground'
        Checked = True
        ShortCut = 123
        OnClick = mnVShowGroundClick
      end
      object mnVSep: TMenuItem
        Caption = '-'
      end
      object mnVOrtho: TMenuItem
        Caption = 'Ortho projection'
        Checked = True
        Default = True
        RadioItem = True
        OnClick = mnVOrthoClick
      end
      object mnVPerspective: TMenuItem
        Caption = 'Perspective projetionn'
        Enabled = False
        RadioItem = True
        OnClick = mnVPerspectiveClick
      end
      object mnVSep3: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object mnVModeRotation: TMenuItem
        Caption = 'rotation'
        Checked = True
        GroupIndex = 1
        RadioItem = True
        ShortCut = 16466
        OnClick = mnVModeRotationClick
      end
      object mnVModeWThrough: TMenuItem
        Caption = 'walk through'
        Enabled = False
        GroupIndex = 1
        RadioItem = True
        ShortCut = 16471
        OnClick = mnVModeWThroughClick
      end
      object mnVSep2: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object mnVFullScreen: TMenuItem
        Caption = 'Fullscreen '
        GroupIndex = 1
        ShortCut = 16454
        OnClick = mnVFullScreenClick
      end
    end
    object mnHelp: TMenuItem
      Caption = '&Help'
      object mnHHelp: TMenuItem
        Caption = 'Help'
        Enabled = False
        ShortCut = 112
      end
      object mnHSep: TMenuItem
        Caption = '-'
      end
      object mnHAbout: TMenuItem
        Caption = 'About program'
        OnClick = mnHAboutClick
      end
    end
  end
  object ppmnObjView: TPopupMenu
    Left = 16
    Top = 16
    object pmnOHide: TMenuItem
      Caption = 'Hide selected'
      ShortCut = 16456
      OnClick = pmnOHideClick
    end
    object pmnOUnhide: TMenuItem
      Caption = 'Unhide selected'
      ShortCut = 16469
      OnClick = pmnOUnhideClick
    end
    object pmnOHideAll: TMenuItem
      Caption = 'HideAll'
      ShortCut = 49224
      OnClick = pmnOHideAllClick
    end
    object pmnOUnhideAll: TMenuItem
      Caption = 'UnhideAll'
      ShortCut = 49237
      OnClick = pmnOUnhideAllClick
    end
  end
end
