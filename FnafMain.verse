using { /Verse.org/Simulation }
using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Game }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
MainDevice := class(creative_device):


    @editable initButton:button_device=button_device{}
    @editable buttonarray : []ui_button = array{}
    

    AnyButtonPressed: event(agent) = event(agent){}
    FailedToCreateCanvas : event(agent) = event(agent){}


    OnBegin<override>()<suspends>:void={
        loop:
            Agent := initButton.InteractedWithEvent.Await().ShowUI();
            Print("Interaction new")
            Sleep(0.1)
    }

    var PlayerUIMap : [player]canvas = map{}
    var LinkedCamera : [player]gameplay_camera_device = map{}



    (Agent:agent).ShowUI():void=
        CloseButton:=button_quiet{DefaultText:=S2M("Exit")}
        var Slots : []canvas_slot = for:
            I -> inbutton:buttonarray
        do:
            data := inbutton
            MainWidget:=button_quiet{DefaultText:=S2M(inbutton.Name)}
            X := canvas_slot:
                Widget:=MainWidget
                Offsets:=margin{Left:=data.OffsetLeft, Top:=data.OffsetTop, Right:=data.OffsetRight, Bottom:=data.OffsetBottom}
                Anchors:=anchors{Minimum:=vector2{X:=1.0,Y:=1.0}, Maximum:=vector2{X:=1.0,Y:=1.0}}
                SizeToContent:=false
            set inbutton.maybeassignedbutton = option{MainWidget}
            Print("Made widget for {data.Name}; button #{I+1}")
            spawn. AwaitButtonPush(Agent, inbutton)
            X
        NewCanvas:=canvas:
            
            
            Slots:=Slots+array{canvas_slot{
                Widget:=CloseButton
                Offsets:=margin{Left:=-320.0, Top:=-92.0, Right:=609.0, Bottom:=86.0}
                Anchors:=anchors{Minimum:=vector2{X:=0.5,Y:=1.0}, Maximum:=vector2{X:=0.5,Y:=1.0}}
                SizeToContent:=false
            
            }
            }
            

        if:
            Player := player[Agent]
            PlayerUI := GetPlayerUI[Player]
        then:
            PlayerUI.AddWidget(NewCanvas, Slot:=player_ui_slot{InputMode:=ui_input_mode.All})
            if. set PlayerUIMap[Player] = NewCanvas
        else:
            Print("Could not get player canvas")
            FailedToCreateCanvas.Signal(Agent)


        spawn{ManageButtonClose(Agent, CloseButton)}

    ManageButtonClose(Agent:agent, tb:text_button_base)<suspends>:void={
        WM := tb.OnClick().Await();
        if:
            WM.Player = player[Agent]
        then:
            Agent.RemoveUI()

    }

    AwaitButtonPush(Agent:agent, inbutton:ui_button)<suspends>:void={
        Print("Awaiting button push for {inbutton.Name}")
        if:
            assignedbutton := inbutton.maybeassignedbutton?
        then:
            race:
                block:
                    WM := assignedbutton.OnClick().Await();
                    Print("{inbutton.Name} was pushed")
                    if:
                        Player:=player[Agent]
                        set LinkedCamera[Player] = inbutton.Camera
                    then: 
                        inbutton.Camera.AddTo(Agent)
                    AnyButtonPressed.Signal(Agent)
                block:
                    loop:
                        testAgent := FailedToCreateCanvas.Await()
                        Print("{inbutton.Name} received that a canvas had failed, checking if agents coorelates.")
                        if(testAgent = Agent):
                            Print("clearing old memory")
                            break

            


    }

    (Agent:agent).RemoveUI():void=
        if:
            Player := player[Agent]
            PlayerUI := GetPlayerUI[Player]
            NewCanvas := PlayerUIMap[Player]
        then:
            Print("Removing UI from player")
            PlayerUI.RemoveWidget(NewCanvas)
        else:
            Print("Failed to remove ui")

        if:
            Player:=player[Agent]
            Camera:=LinkedCamera[Player]
        then:
            Camera.RemoveFrom(Player)
            Print("Removed Cam")
        else:
            Print("Failed to remove camera")





                    

            
                

    
    S2M<localizes>(SM:string)<transacts>:message="{SM}"

    
ui_button<public>:=class:

    @editable var <public> Name:string="My Camera"
    @editable var <public> Camera : gameplay_camera_fixed_point_device = gameplay_camera_fixed_point_device{}
    @editable var <public> OffsetLeft:float=0.0
    @editable var <public> OffsetTop:float=0.0
    @editable var <public> OffsetRight:float=0.0
    @editable var <public> OffsetBottom:float=0.0

    var maybeassignedbutton : ?text_button_base = false



