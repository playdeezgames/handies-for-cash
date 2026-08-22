Imports System.Runtime.CompilerServices
Imports Metaphor.Persistence

Public Module FeatureExtensions
    <Extension>
    Public Function IsHidden(feature As IFeature) As Boolean
        Return feature.HasTag(Tags.HIDDEN)
    End Function
#Region "Describe"
    Private Sub DescribeFeature(feature As IFeature)
        feature.AddMessage($"It is a {feature.Name}.")
    End Sub
    Private Delegate Sub FeatureDescriber(feature As IFeature)
    Private ReadOnly featureDescribers As New Dictionary(Of String, FeatureDescriber) From
        {
            {FeatureSubtypes.CHECKPOINT, AddressOf DescribeCheckpoint}
        }

    Private Sub DescribeCheckpoint(feature As IFeature)
        DescribeFeature(feature)
        Dim avatar = feature.World.Avatar
        If avatar.IsCurrentCheckpoint(feature) Then
            avatar.AddMessage($"This is {avatar.Name}'s current checkpoint.")
        End If
    End Sub

    <Extension>
    Public Sub Describe(feature As IFeature)
        Dim describer As FeatureDescriber = Nothing
        If featureDescribers.TryGetValue(feature.EntitySubtype, describer) Then
            describer.Invoke(feature)
        Else
            DescribeFeature(feature)
        End If
    End Sub
#End Region
#Region "Destination"
    <Extension>
    Public Sub SetDestination(feature As IFeature, destination As ILocation)
        feature.SetYoke(Yokes.DESTINATION, destination.EntityId)
    End Sub
    <Extension>
    Public Function GetDestination(feature As IFeature) As ILocation
        Return feature.World.GetLocation(feature.GetYoke(Yokes.DESTINATION))
    End Function
#End Region
End Module
