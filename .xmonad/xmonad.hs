import XMonad
import XMonad.StackSet as W
import qualified Data.Map as M
import Data.Monoid
import Data.List
import Data.Tree
import XMonad.Actions.TreeSelect
import XMonad.Actions.FloatKeys
import XMonad.Actions.DynamicProjects
import XMonad.Actions.Navigation2D
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.WindowSwallowing
import XMonad.Hooks.RefocusLast
import XMonad.Layout.Drawer
import XMonad.Layout.Groups.Examples
import XMonad.Layout.TrackFloating
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Spacing
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.Tabbed
import XMonad.Layout.SubLayouts
import XMonad.Layout.Simplest
import XMonad.Layout.NoBorders
import XMonad.Util.NamedScratchpad
import XMonad.Util.WorkspaceCompare
import XMonad.Util.EZConfig
main :: IO()
main = 
  xmonad $ addEwmhWorkspaceSort (pure myFilter) . ewmhFullscreen . ewmh $ docks $ dynamicProjects projects $
   navigation2DP myNav2DConf
   ("e", "h", "n", "i") [
    ("M-",   windowGo),
    ("M-C-", windowSwap)
    ] False $
    def {
    terminal           = "alacritty",
    manageHook         = myManageHook,
    modMask            = mod4Mask,
    borderWidth        = 2,
    focusedBorderColor = "#d3d0c8",
    normalBorderColor  = "#2d2d2d",
    XMonad.workspaces  = toWorkspaces myWorkspaces,
    handleEventHook    = refocusLastWhen refocusingIsActive <+>
                         swallowEventHook (className =? "Alacritty" <||>
                                           className =? "Termite") (return True),
                         -- <+>
                         -- XMonad.Layout.Fullscreen.fullscreenEventHook,
    mouseBindings      = myMouseBindings,
    logHook            = refocusLastLogHook,
    layoutHook         =
        refocusLastLayoutHook . trackFloating $ configurableNavigation noNavigateBorders $
        -- fullscreenFull $
        smartBorders $
        mkToggle (single NBFULL) $
        avoidStruts $


        (addTabs shrinkText myTabConfig $
        subLayout [] Simplest $
        mySpacing $ 
        Tall 1 (3/100) (1/2) |||

        (mySpacing $ simpleDrawer 0.01 0.3 (ClassName "Emacs" `Or` ClassName "alacritty")  `onRight` (Tall 1 0.03 0.5)) ) |||
        (mySpacing $ tabbed shrinkText myTabConfig)
      
    }
  `additionalKeysP` myKeys

myFilter = filterOutWs [scratchpadWorkspaceTag]

mySpacing = 
  spacingRaw False (Border 8 8 8 8) True (Border 8 8 8 8) True
  
myMouseBindings :: XConfig Layout -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList [
  ((modMask, button1), \w -> XMonad.focus w >> mouseMoveWindow w
                                            >> windows W.shiftMaster),

  ((modMask, button2), windows . (W.shiftMaster .) . W.focusWindow),

  ((modMask, button2), windows . (W.shiftMaster .) . W.focusWindow),

  ((modMask, button3), \w -> XMonad.focus w >> mouseResizeWindow w
                                         >> windows W.shiftMaster),
  ((modMask, button3), \w -> XMonad.focus w >> mouseResizeWindow w
                                         >> windows W.shiftMaster),
  ((modMask .|. controlMask, button1), \w -> XMonad.focus w >> mouseResizeWindow w
                                         >> windows W.shiftMaster)
    ]

-- make polybar lower itself
polybarFix = ask >>= \w -> liftX $ withDisplay $ \dpy -> io (lowerWindow dpy w) >> mempty

myManageHook :: Query (Endo WindowSet)
myManageHook = 
  manageHook def <+>
  manageDocks <+>
  namedScratchpadManageHook scratchpads <+>
  composeOne [
  -- Force dialog windows and pop-ups to be floating.
  isDialog                                    -?> doCenterFloat,
  stringProperty "WM_WINDOW_ROLE" =? "pop-up" -?> doCenterFloat,
  transience, -- Move transient windows to their parent.
  -- className =? "qutebrowser"  -?> doShift "Web",
  -- className =? "Riot"         -?> doShift "Riot",
  className =? "feh"          -?> doFloat,
  className =? "Lxappearance" -?> doFloat,
  className =? "mpv"          -?> doFloat,
  className =? "net-minecraft-launcher-Main" -?> doFloat,
  className =? "TelegramDesktop" -?> doFloat,
  className =? "net-minecraft-bootstrap-Bootstrap" -?> doFloat,
  className =? "polybar" --> polybarFix,
  title =?     "CS 240 Project"  -?> doFloat,
    -- zoom's temporary windows just have zoom title
  title =?     "zoom" -?> doFloat,
  pure True -?> insertPosition End Newer
  ]

scratchpads :: [NamedScratchpad]
scratchpads = [
  NS "telegram" "telegram-desktop" (className =? "TelegramDesktop")
    (customFloating $ W.RationalRect (1/4) (1/6) (1/2) (2/3)),

  NS "ncmpcpp" "alacritty --class ncmpcpp,ncmpcpp -e ncmpcpp'"
    (className =? "ncmpcpp")
    (customFloating $ W.RationalRect (1/4) (1/3) (1/2) (1/3)),

  -- NS "term" "alacritty --class scratchpad,scratchpad" (className =? "scratchpad")
  --   (customFloating $ W.RationalRect (1/4) (1/3) (1/2) (1/3))

  NS "term" "emacsclient -c -a \"\" -F \"'(name . \\\"scratchpad\\\")\" -e \"(my/eshell-scratchpad)\"" (title =? "scratchpad")
    (customFloating $ W.RationalRect (1/4) (1/3) (1/2) (1/3))

  -- NS "riot" "riot-web" (className =? "Riot") nonFloating
  ]

myTabConfig :: Theme
myTabConfig = def {
  activeColor = "#393939",
  inactiveColor = "#393939",
  activeBorderColor = "#d3d0c8",
  inactiveBorderColor = "#d3d0c8",
  activeTextColor = "#6699cc",
  inactiveTextColor = "#d3d0c8",
  urgentTextColor = "#ff0000",
  fontName = "xft:Lato:size=10",
  decoHeight = 50
  }

toggleFloat :: X()
toggleFloat = withFocused $ \windowId -> do {
  floats <- gets (W.floating . windowset);
  if windowId `M.member` floats
  then withFocused $ windows . W.sink
  else do
    keysResizeWindow (-100, -100) (0.5, 0.5) windowId
  }


myWorkspaces :: Forest String
myWorkspaces = [
  Node "Term" [
      Node "2" [],
      Node "3" [],
      Node "4" []
      ],
  Node "Web" [
      Node "2" [],
      Node "3" [],
      Node "4" [],
      Node "5" [],
      Node "6" []
      ],
  -- Node "Riot" [],
  Node "Study" [
      Node "2" [],
      Node "3" [],
      Node "4" []
      ],
  Node "Prog" [
      Node "Term" [],
      Node "Docs" []
      ],
  Node "Misc" [
      Node "2" [],
      Node "3" [],
      Node "4" []
      ],
  Node "Music" [
      Node "2" [],
      Node "3" [],
      Node "4" []
      ],
  Node "Gaming" [
      Node "Minecraft" [],
      Node "Melee" [],
      Node "Mario Kart" [],
      Node "P+" []
      ]
  -- Node "NSP" []
  ]

-- colors are arbg for some reason
myTSConfig :: TSConfig a
myTSConfig = TSConfig {
  ts_hidechildren = True,
  ts_background   = 0x902d2d2d,
  ts_font         = "xft:Sans-11",
  ts_node         = (0xffebb2db, 0xff322f30),
  ts_nodealt      = (0xffebb2db, 0xff282828),
  ts_highlight    = (0xfffbc7f1, 0xff665c54),
  ts_extra        = 0xffebb2db,
  ts_node_width   = 200,
  ts_node_height  = 36,
  ts_originX      = 100,
  ts_originY      = 100,
  ts_indent       = 20,
  ts_navigate     = M.fromList [
      ((0, xK_Escape), cancel),
      ((0, xK_q),      cancel),
      ((0, xK_Return), select),
      ((0, xK_space),  select),
      ((0, xK_Up),     movePrev),
      ((0, xK_Down),   moveNext),
      ((0, xK_Left),   moveParent),
      ((0, xK_Right),  moveChild),
      ((0, xK_e),      movePrev),
      ((0, xK_n),      moveNext),
      ((0, xK_h),      moveParent),
      ((0, xK_i),      moveChild),
      ((0, xK_l),      moveHistBack),
      ((0, xK_u),      moveHistForward)
    ]
  }

projects :: [Project]
projects = [
  Project {
      projectName      = "Term",
      projectDirectory = "~/",
      projectStartHook = Nothing
      },
  Project {
      projectName      = "Term.2",
      projectDirectory = "~/",
      projectStartHook = Nothing
      },
  Project {
      projectName      = "Term.3",
      projectDirectory = "~/",
      projectStartHook = Nothing
      },
  Project {
      projectName      = "Term.4",
      projectDirectory = "~/",
      projectStartHook = Nothing
      },

  Project {
      projectName      = "Web",
      projectDirectory = "~/",
      -- projectStartHook = Just $ do spawn "qutebrowser-wrapped --restore web"
      projectStartHook = Just $ do spawn "qutebrowser"
      },

  -- Project {
  --     projectName      = "Riot",
  --     projectDirectory = "~/",
  --     projectStartHook = Just $ do spawn "riot-web"
  --     },

  Project {
      projectName      = "Study",
      projectDirectory = "~/",
      projectStartHook = Nothing
      },
  Project {
      projectName      = "Study.2",
      projectDirectory = "~/",
      projectStartHook = Nothing
      },
  Project {
      projectName      = "Study.3",
      projectDirectory = "~/",
      projectStartHook = Nothing
      },
  Project {
      projectName      = "Study.4",
      projectDirectory = "~/",
      projectStartHook = Nothing
      },

  Project {
      projectName      = "Prog",
      projectDirectory = "~/",
      projectStartHook = Nothing
      },

  Project {
      projectName      = "Music",
      projectDirectory = "~/",
      projectStartHook = Just $ do spawn "soulseek"
      },

  Project {
      projectName      = "Gaming.P+",
      projectDirectory = "/data/media/dolphin",
      projectStartHook = Just $ do spawn "ssbp+"
      },

  Project {
      projectName      = "Gaming.Melee",
      projectDirectory = "/data/media/dolphin",
      projectStartHook = Just $ do spawn "melee"
      },

  Project {
      projectName      = "Gaming.Mario Kart",
      projectDirectory = "/data/media/dolphin",
      projectStartHook = Just $ do spawn "mariokart"
      },

  Project {
      projectName      = "Gaming.Minecraft",
      projectDirectory = "~/",
      projectStartHook = Just $ do spawn "minecraft-launcher"
      }
  ]

myNav2DConf :: Navigation2DConfig
myNav2DConf = def {
  -- defaultTiledNavigation    = hybridNavigation,
  defaultTiledNavigation    = hybridOf sideNavigation centerNavigation,
  floatNavigation           = centerNavigation,
  screenNavigation          = lineNavigation,
  layoutNavigation          = [("Full", centerNavigation)],
  unmappedWindowRect        = [("Full", singleWindowRect)]
  }

  
-- removes characters after (and including) the last .
chopToDot :: String -> String
chopToDot str =
  chopToDot' str str
  
chopToDot' :: String -> String -> String
chopToDot' str initValue =
  if str == ""
  then initValue
  else if (last str) == '.'
       then init str
       else chopToDot' (init str) initValue

-- returns the elements that belong to the same node
getSiblings :: String -> [ String ] -> [ String ]
getSiblings currentlyFocusedTag workspaceList =
  Prelude.filter (baseEquals baseTag) workspaceList
  where baseTag = chopToDot currentlyFocusedTag
        baseEquals x y = x == chopToDot y


getChildWorkspace :: Int -> String -> [ String ] -> String
getChildWorkspace n currentWorkspace workspaceList =
  getSiblings currentWorkspace workspaceList !! n

  
  
switchToChildWorkspace :: Int -> X()
switchToChildWorkspace n = do
   ws <- gets windowset
   windows $ W.greedyView $
     getChildWorkspace n (W.tag . W.workspace $ W.current ws) $
     toWorkspaces myWorkspaces


shiftToChildWorkspace :: Int -> X()
shiftToChildWorkspace n = do
   ws <- gets windowset
   windows $ W.shift $
     getChildWorkspace n (W.tag . W.workspace $ W.current ws) $
     toWorkspaces myWorkspaces

switchToNextChild :: X()
switchToNextChild = do
  ws <- gets windowset
  let workspaceIndex = ((W.tag . W.workspace $ W.current ws) `position` toWorkspaces myWorkspaces)
      currentWorkspace = (toWorkspaces myWorkspaces !! workspaceIndex)
      nextWorkspace = (toWorkspaces myWorkspaces !! (workspaceIndex + 1))
    in
    if chopToDot currentWorkspace == chopToDot nextWorkspace
    then windows $ W.greedyView $ nextWorkspace
    else switchToChildWorkspace 0

  
shiftToNextChild :: X()
shiftToNextChild = do
  ws <- gets windowset
  let workspaceIndex = ((W.tag . W.workspace $ W.current ws) `position` toWorkspaces myWorkspaces)
      currentWorkspace = (toWorkspaces myWorkspaces !! workspaceIndex)
      nextWorkspace = (toWorkspaces myWorkspaces !! (workspaceIndex + 1))
    in
    if chopToDot currentWorkspace == chopToDot nextWorkspace
    then windows $ W.shift $ nextWorkspace
    else switchToChildWorkspace 0

switchToPreviousChild :: X()
switchToPreviousChild = do
  ws <- gets windowset
  let workspaceName = (W.tag . W.workspace $ W.current ws)
      workspaceIndex = (workspaceName `position` toWorkspaces myWorkspaces)
      currentWorkspace = (toWorkspaces myWorkspaces !! workspaceIndex)
      lastChild = length (getSiblings workspaceName (toWorkspaces myWorkspaces)) -1
    in
    if workspaceIndex == 0
    then switchToChildWorkspace lastChild
    else
      let
        previousWorkspace = (toWorkspaces myWorkspaces !! (workspaceIndex - 1))
      in
        if chopToDot currentWorkspace == chopToDot previousWorkspace
        then windows $ W.greedyView $ previousWorkspace
        else switchToChildWorkspace lastChild

shiftToPreviousChild :: X()
shiftToPreviousChild = do
  ws <- gets windowset
  let workspaceName = (W.tag . W.workspace $ W.current ws)
      workspaceIndex = (workspaceName `position` toWorkspaces myWorkspaces)
      currentWorkspace = (toWorkspaces myWorkspaces !! workspaceIndex)
      lastChild = length (getSiblings workspaceName (toWorkspaces myWorkspaces)) -1
    in
    if workspaceIndex == 0
    then switchToChildWorkspace lastChild
    else
      let
        previousWorkspace = (toWorkspaces myWorkspaces !! (workspaceIndex - 1))
      in
        if chopToDot currentWorkspace == chopToDot previousWorkspace
        then windows $ W.shift $ previousWorkspace
        else switchToChildWorkspace lastChild

position :: Eq a => a -> [a] -> Int
position i list =
    case i `elemIndex` list of
       Just n  -> n
       Nothing -> 0
  
getParentWorkspace :: X String
getParentWorkspace = do
    ws <- gets windowset
    return $ chopToDot $ (W.tag . W.workspace . W.current) $ ws

spawnQutebrowserSession :: X()
spawnQutebrowserSession = do
  ws <- getParentWorkspace
  case ws of "Web"    -> spawn "qutebrowser-wrapped --restore web"
             "Term"   -> spawn "qutebrowser-wrapped --restore term"
             "Study"  -> spawn "qutebrowser-wrapped --restore study"
             "Misc"   -> spawn "qutebrowser-wrapped --restore misc"
             "Gaming" -> spawn "qutebrowser-wrapped --restore gaming"
             _        -> spawn "qutebrowser-wrapped"

toggleMinecraft :: X()
toggleMinecraft = do
   ws <- gets windowset
   windows $ W.greedyView $
     if (W.tag . W.workspace $ W.current ws) == "Gaming.Minecraft"
     then
       "Web"
     else
       "Gaming.Minecraft"
  
myKeys :: [([Char], X())]
myKeys = [
  ("M-,",           switchToPreviousChild),
  ("M-S-,",         shiftToPreviousChild),
  ("M-.",           switchToNextChild),
  ("M-S-.",         shiftToNextChild),
  ("M-<Return>",    spawn "eshell"),
  -- ("M-<Return>",    spawn "alacritty"),
  -- ("M-S-<Return>",  spawnQutebrowserSession),
  ("M-f",           toggleFloat),
  ("M-o",           namedScratchpadAction scratchpads "term"),
  ("M-`",           namedScratchpadAction scratchpads "ncmpcpp"),
  ("M-'",           namedScratchpadAction scratchpads "telegram"),
  ("M-c",           kill),
  ("M-C-,",         sendMessage (IncMasterN 1)),
  ("M-C-.",         sendMessage (IncMasterN (-1))),
  ("M-u",           onGroup W.focusUp'),
  ("M-y",           onGroup W.focusDown'),
  ("M-S-u",         sendMessage (IncMasterN 1)),
  ("M-S-y",         sendMessage (IncMasterN (-1))),
  ("M-[",           sendMessage Shrink),
  ("M-]",           sendMessage Expand),
  ("M-C-<Tab>",     switchLayer),
  ("<F11>",         sendMessage $ Toggle NBFULL),
  ("M-S-h",         sendMessage $ pullGroup L),
  ("M-S-n",         sendMessage $ pullGroup D),
  ("M-S-e",         sendMessage $ pullGroup U),
  ("M-S-i",         sendMessage $ pullGroup R),
  ("M-<Escape>",    withFocused $ sendMessage . UnMerge),
  ("M-/",           spawn "rofi -show run"),
  ("M-w",           spawn "rofi -show window -width 40"),
  ("M-q",           spawn "rofi -show session"), 
  ("M-x",           spawn "emacsclient -c -a \"\""),
  ("M-S-x",         spawn "emacs"),
  ("M-p",           spawn "rofi-pass"),
  ("M-z",           spawn "xmonad --recompile; xmonad --restart"),
  ("M-<Up>",        spawn "change_volume + > /dev/null"),
  ("M-<Down>",      spawn "change_volume - > /dev/null"),
  ("M-<Right>",     spawn "xbacklight -inc 10"),
  ("M-<Left>",      spawn "xbacklight -dec 10"),
  ("M-<Backspace>", spawn "lock"),
  ("M-\\",          spawn "toggle-keyboard-layout"),
  ("M-S-<Escape>",  toggleMinecraft),

  ("M-1",           switchToChildWorkspace 0),
  ("M-2",           switchToChildWorkspace 1),
  ("M-3",           switchToChildWorkspace 2),
  ("M-4",           switchToChildWorkspace 3),
  ("M-5",           switchToChildWorkspace 4),
  ("M-6",           switchToChildWorkspace 5),
  ("M-7",           switchToChildWorkspace 6),

  ("M-S-1",         shiftToChildWorkspace 0),
  ("M-S-2",         shiftToChildWorkspace 1),
  ("M-S-3",         shiftToChildWorkspace 2),
  ("M-S-4",         shiftToChildWorkspace 3),
  ("M-S-5",         shiftToChildWorkspace 4),
  ("M-S-6",         shiftToChildWorkspace 5),
  ("M-S-7",         shiftToChildWorkspace 6),

  ("M-t",           windows $ W.greedyView "Term"),
  ("M-b",           windows $ W.greedyView "Web"),
  -- ("M-r",           windows $ W.greedyView "Riot"),
  ("M-s",           windows $ W.greedyView "Study"),
  ("M-k",           windows $ W.greedyView "Prog"),
  ("M-m",           windows $ W.greedyView "Misc"),
  ("M-C-m",         windows $ W.greedyView "Music"),
  ("M-g",           windows $ W.greedyView "Gaming"),
  ("M-6",           spawn ""),
  ("M-7",           spawn ""),
  ("M-8",           spawn ""),
  ("M-9",           spawn ""),

  ("M-S-t",         windows $ W.shift "Term"),
  ("M-S-b",         windows $ W.shift "Web"),
  -- ("M-S-r",         windows $ W.shift "Riot"),
  ("M-S-s",         windows $ W.shift "Study"),
  ("M-S-k",         windows $ W.shift "Prog"),
  ("M-S-m",         windows $ W.shift "Misc"),
  ("M-S-C-m",       windows $ W.shift "Music"),
  ("M-S-g",         windows $ W.shift "Gaming"),
  ("M-S-6",         spawn ""),
  ("M-S-7",         spawn ""),
  ("M-S-8",         spawn ""),
  ("M-S-9",         spawn ""),

  ("M-S-<Space>",   treeselectWorkspace
                    myTSConfig
                    myWorkspaces W.greedyView),
  ("M-C-<Space>",   treeselectWorkspace
                    myTSConfig
                    myWorkspaces
                    W.shift)
  ]
