:Namespace SampleApp

      RunSample←{
     
          path←(0⊃⎕nparts #.GetEnvironment'DYAPP' ),'FmtBuilder_Demo_App\apitest.html'

          h5←⎕NEW #.H5Resource path
          h5.Debug←1
          h5.DisplayLogWindow←1
     
          ep←⎕NEW #.H5APIEndPoint
          ep.Path←h5.APIEntryPath,'FormatStringBuilder'
          ep.GET←'#.FmtBuilder.getFmtIntitial'
          ep.POST←'#.FmtBuilder.getPostResponse'
     
          h5.APIEndPoints←,⊂ep
     
          ob←h5.Show
          ob
     
      }


:EndNamespace
