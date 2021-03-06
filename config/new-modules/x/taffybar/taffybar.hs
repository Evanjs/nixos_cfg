-- -*- mode:haskell -*-
{-# LANGUAGE OverloadedStrings #-}
module Main where
import           Control.Monad
import           Control.Monad.IO.Class
import           Control.Monad.Trans                         (liftIO)
import qualified Data.ByteString.Lazy                        as L
import qualified Data.ByteString.Lazy.Char8                  as Char8
import           Data.Char                                   (isSpace)
import qualified Data.Text                                   as T
import qualified Graphics.UI.Gtk                             as G
import           Data.IORef
import           System.Exit                                 (ExitCode)
import           System.IO                                   (hClose, hPutStr)
import           System.Process
import           System.Taffybar
import qualified System.Taffybar.Context                     as C
import           System.Taffybar.Hooks
import           System.Taffybar.Information.CPU
import           System.Taffybar.Information.Memory
import           System.Taffybar.SimpleConfig
import           System.Taffybar.Util                        (logPrintF)
import           System.Taffybar.Widget
import           System.Taffybar.Widget.Generic.PollingGraph
import           System.Taffybar.Widget.Generic.PollingLabel
import           System.Taffybar.Widget.Util
import           System.Taffybar.Widget.Workspaces
import           Text.Printf
import           Data.Time.Format


transparent = (0.0, 0.0, 0.0, 0.0)
yellow1 = (0.9453125, 0.63671875, 0.2109375, 1.0)
yellow2 = (0.9921875, 0.796875, 0.32421875, 1.0)
green1 = (0, 1, 0, 1)
green2 = (1, 0, 1, 0.5)
taffyBlue = (0.129, 0.588, 0.953, 1)

myGraphConfig =
  defaultGraphConfig
  { graphPadding = 0
  , graphBorderWidth = 0
  , graphWidth = 75
  , graphBackgroundColor = transparent
  }

netCfg = myGraphConfig
  { graphDataColors = [yellow1, yellow2]
  , graphLabel = Just $ T.pack "net"
  }

memCfg = myGraphConfig
  { graphDataColors = [taffyBlue]
  , graphLabel = Just $ T.pack "mem"
  }

cpuCfg = myGraphConfig
  { graphDataColors = [green1, green2]
  , graphLabel = Just $ T.pack "cpu"
  }

-- TC: KTVC
-- Dowagiac: KBEH
wcfg = (defaultWeatherConfig "KTVC") { weatherTemplate = "$tempF$ F / $tempC$ C - $skyCondition$" }

memCallback :: IO [Double]
memCallback = do
  mi <- parseMeminfo
  return [memoryUsedRatio mi]

cpuCallback = do
  (_, systemLoad, totalLoad) <- cpuLoad
  return [totalLoad, systemLoad]

stripStr :: IO String -> IO String
stripStr ioString = rstrip <$> ioString

rstrip = reverse . dropWhile isSpace . reverse

jpLocale = defaultTimeLocale
    { wDays =
        [ ("日曜日", "日")
        , ("月曜日", "月")
        , ("火曜日", "火")
        , ("水曜日", "水")
        , ("木曜日", "木")
        , ("金曜日", "金")
        , ("土曜日", "土")
        ]
    }

main = do
  let myWorkspacesConfig =
        defaultWorkspacesConfig
        { minIcons = 1
        , widgetGap = 0
        , showWorkspaceFn = hideEmpty
        }
      workspaces = workspacesNew myWorkspacesConfig
      --cpu = pollingGraphNew cpuCfg 0.5 cpuCallback
      --mem = pollingGraphNew memCfg 1 memCallback
      --net = networkGraphNew netCfg Nothing
      clock = textClockNew (Just jpLocale) "(%a)   %b %_d  %X" 60
      layout = layoutNew defaultLayoutConfig
      windows = windowsNew defaultWindowsConfig
      {-kernel = shellWidgetNew (T.pack "...") "echo -e \"Cur: $(uname -r)\"" 86400 -}
      weather = liftIO $ weatherNew wcfg 30
          -- See https://github.com/taffybar/gtk-sni-tray#statusnotifierwatcher
          -- for a better way to set up the sni tray
      tray = sniTrayThatStartsWatcherEvenThoughThisIsABadWayToDoIt


      myConfig = defaultSimpleTaffyConfig
        { startWidgets =
            workspaces : map (>>= buildContentsBox) [ layout, windows ]
        , endWidgets = map (>>= buildContentsBox)
          [
            clock
          , tray
          --, cpu
          --, mem
          --, net
          , weather
          ]
        , barPosition = Top
        , barPadding = 10
        , barHeight = 50
        , widgetSpacing = 8
        }
  startTaffybar $ withLogServer $ withToggleServer $
               toTaffyConfig myConfig
