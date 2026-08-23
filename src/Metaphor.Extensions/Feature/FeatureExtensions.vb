Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module FeatureExtensions
    <Extension>
    Public Sub Describe(feature As IFeature)
        feature.AddMessage($"TODO: Describe {feature.Name}.")
    End Sub
#Region "Destination"
    <Extension>
    Sub SetDestination(feature As IFeature, destination As ILocation)
        feature.SetYoke(Yokes.DESTINATION, destination.EntityId)
    End Sub
    <Extension>
    Function GetDestination(feature As IFeature) As ILocation
        Return feature.World.GetLocation(feature.GetYoke(Yokes.DESTINATION))
    End Function
#End Region
End Module
