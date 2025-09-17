object Dmbase: TDmbase
  OnCreate = DataModuleCreate
  Height = 386
  Width = 553
  PixelsPerInch = 120
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    DriverID = 'MySQL'
    Left = 256
    Top = 96
  end
  object DBMySQL: TFDConnection
    Params.Strings = (
      'DriverID=MySQL'
      'Database=base_wk'
      'Server=127.0.0.1'
      'Port=3306'
      'User_Name=root'
      'Password=masterkey')
    LoginPrompt = False
    Left = 96
    Top = 96
  end
end
