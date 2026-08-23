Imports Metaphor.Persistence

Friend Module LocationInitializationExtensions
#Region "Abandoned House"
    Friend Function InitializeAbandonedHouse(chosenName As String) As Persistence.LocationInitializer
        Return Sub(room)
                   room.CreateStainedMattress()
                   room.CreateN00b(chosenName)
                   room.CreateDoors(room.World.CreateOutside())
               End Sub
    End Function
#End Region
#Region "Outside"
    Friend Sub InitializeOutside(location As ILocation)
        location.CreateDoors(location.World.CreateDarkAlley())
    End Sub
#End Region
#Region "Dark Alley"
    Friend Sub InitializeDarkAlley(location As ILocation)
        location.CreateVerb(VerbSubtypes.SOLICIT, "Solicit")
    End Sub
#End Region
End Module
