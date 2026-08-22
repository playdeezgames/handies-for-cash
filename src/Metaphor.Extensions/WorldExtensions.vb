Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module WorldExtensions
#Region "Abandoned House"
    <Extension>
    Private Sub CreateAbandonedHouse(world As IWorld, context As IInitializationContext)
        world.CreateLocation(
            LocationSubtypes.ABANDONED_HOUSE,
            "The Abandoned House",
            InitializeAbandonedHouse(context.ChosenName))
    End Sub
    Friend Function InitializeAbandonedHouse(chosenName As String) As Persistence.LocationInitializer
        Return Sub(room)
                   room.CreateN00b(chosenName)
                   room.CreateDoors(room.World.CreateOutside())
               End Sub
    End Function
#End Region
#Region "Outside"
    <Extension>
    Private Function CreateOutside(world As IWorld) As ILocation
        Return world.CreateLocation(LocationSubtypes.OUTSIDE, "Outside", AddressOf InitializeOutside)
    End Function

    Private Sub InitializeOutside(location As ILocation)
        location.CreateDoors(location.World.CreateDarkAlley())
    End Sub
#End Region
#Region "Dark Alley"
    <Extension>
    Private Function CreateDarkAlley(world As IWorld) As ILocation
        Return world.CreateLocation(LocationSubtypes.DARK_ALLEY, "Dark Alley", AddressOf InitializeDarkAlley)
    End Function

    Private Sub InitializeDarkAlley(location As ILocation)
    End Sub
#End Region
    <Extension>
    Public Sub Initialize(world As IWorld, context As IInitializationContext)
        world.Clear()
        world.CreateAbandonedHouse(context)
        world.AddMessage("Welcome to Handies for Cash!")
        world.Avatar.Look()
    End Sub
End Module
