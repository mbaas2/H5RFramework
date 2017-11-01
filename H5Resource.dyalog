:Class H5Resource
    ⎕io←0
    ⎕ml←3

    :field private _html ←''
    :field private _resourceName←''
    :field private _resourceFolder←''
    :field private _debug ←0
    :field private _apiEndPoints ← ⎕null
    :field private _apiEntryPath ← '/'

    ∇ const pagePath
      :Access public
      :Implements constructor
     
      :If ~⎕NEXISTS pagePath
          ⎕SIGNAL('EN' 1)('Message' 'Invalid path.')
      :End
     
      :If 2≠1 ⎕NINFO pagePath
          ⎕SIGNAL('EN' 11)('Message' 'Path is not a file.')
      :EndIf
     
      _resourceFolder _resourceName←{(0⊃⍵)(∊1↓⍵)}⎕NPARTS pagePath
      _resourceFolder←fixPath ¯1↓_resourceFolder
      _html←GetFileContent pagePath
    ∇

    ∇ Z←Show;hrObj
      :Access public instance
     
      :If (≢_apiEntryPath)<1
          addLogMsg'APIEntryPath is not set.'
      :EndIf
     
      hrObj←⎕NEW'HTMLRenderer'(('Coord' 'Pixel')('Size'(550 650)))
      hrObj.onHTTPRequest←'processRequest'
      hrObj.HTML←_html
      Z←hrObj
    ∇

    ∇ Z←processRequest request;url;endpontCallback;resourceType;reqResource;message;response;endpoint
      :Access private instance
     
      message←⎕NEW #.H5Message request
      addLogMsg'Request URL: ',message.URL
      addLogMsg'Reqeust Type: ',message.Method
     
      :If ~message.IsValidDomain      
          response←⎕NEW #.H5Message message
          response.StatusCode←405
          response.StatusMessage←'Unacceptable request domain: ',message.RequestDomain
          LogResponseDetails response
          Z←response.ToHTMLRenderer
          :Return
      :EndIf
     
      resourceType←GetResourceType message.RequestPath
      addLogMsg'Request Resource: ',resourceType
     
      :If resourceType≡'api'
     
          endpoint←GetApiEndPoint message.RequestPath
     
          :If endpoint≢⎕NULL
     
              :Trap 6
                  endpontCallback←endpoint⍎message.Method
              :Else
     
                  response←⎕NEW #.H5Message message
                  response.StatusCode←404
                  response.StatusMessage←'API end-point does not contain callback definition for method: ',message.Method
                  →getout
              :EndTrap
     
              addLogMsg'Request Process Callback: ',endpontCallback
     
              :Trap 0
     
                  response←message(⍎endpontCallback)''
     
              :Else
     
                  response←⎕NEW #.H5Message message
                  response.StatusCode←500
                  response.StatusMessage←'Error executing: ',endpontCallback
     
              :EndTrap
          :Else
     
              response←⎕NEW #.H5Message message
              response.StatusCode←404
              response.StatusMessage←'No valid API end-point.'
     
          :EndIf
     
      :ElseIf (resourceType≡'file')∧('GET'≡message.Method)
     
          response←message SendFileResource ResourceFolder,message.RequestPath
     
      :Else
     
          response←⎕NEW #.H5Message message
          response.StatusCode←404
          response.StatusMessage←'No valid resource or API end-point.'
     
      :EndIf
     
     getout:
     
      LogResponseDetails response
     
      Z←response.ToHTMLRenderer
    ∇

    ∇ LogResponseDetails response
     
      →(~Debug)/0
     
      addLogMsg'Response Mime-Type: ',response.MimeType
      addLogMsg'Response Status Code: ',⍕response.StatusCode
      addLogMsg'Response Status Message: ',response.StatusMessage
      addLogMsg'Response Legth: ',⍕≢response.Content
     
      :If response.MimeType≡'appllication/json'
          addLogMsg'Response Content: ',response.Content
      :Else
          addLogMsg'Response Content (partial): ',{(≢⍵)>50:50↑⍵ ⋄ ⍵}response.Content
      :EndIf
     
      addLogMsg''
    ∇

      GetApiEndPoint←{
          epcount←≢APIEndPoints
          0=epcount:⎕NULL
          ep←APIEndPoints[⍒⊃APIEndPoints.Path]  ⍝ sort endponts.. may need a better paln
          epTestPath←⍵∘{⍵↑⍺}¨(≢¨ep.Path)
          index←⍸ep.Path∊epTestPath
          0=≢index:⎕NULL
          index⊃ep
      }

      IsApiEndPoint←{
          ep←GetApiEndPoint ⍵
          ep≡⎕NULL:0
          1
      }

      GetResourceType←{
          IsApiEndPoint ⍵:'api'
          exists←⎕NEXISTS ResourceFolder,⍵
          ~exists:'n/a'
          res←↑(1 2∊1 ⎕NINFO ResourceFolder,⍵)/'directory' 'file'
          res
      }

    :property APIEntryPath
    :access public instance

        ∇ r←get
          r←_apiEntryPath
        ∇

        ∇ set arg
          _apiEntryPath←arg.NewValue
        ∇
    :endproperty

    :property APIEntryPathVec
    :access public instance

        ∇ r←get
          r←{(⍵≠'/')⊆⍵}_apiEntryPath
        ∇
    :endproperty

    :property APIEndPoints
    :access public instance
        ∇ r←get
          r←_apiEndPoints
        ∇

        ∇ set args
          _apiEndPoints←args.NewValue
        ∇
    :endproperty

    :property Debug
    :access public instance

        ∇ r←get
          r←_debug
        ∇

        ∇ set arg
          _debug←arg.NewValue
        ∇

    :endproperty

    :property ResourceFolder
    :access public instance
        ∇ r←get
          r←_resourceFolder
        ∇
    :endproperty

    :property DomainRootLength
    :access public instance
        ∇ r←get
          r←≢_domainRoot
        ∇

    :endproperty

    ∇ Z←GetFileContent path
      :Access public shared
      :Trap 92
          Z←0⊃⎕NGET path
      :Else
          Z←rawread path
      :EndTrap
    ∇

      rawread←{              ⍝ Read native file ⍵
          t←⍵ ⎕NTIE 0        ⍝ Tie w/nxt avail num<
          s←⎕NSIZE t         ⍝ Bytes
          b←⎕NREAD t 80 s 0  ⍝ Read em all
          t←⎕NUNTIE t        ⍝ Untie it
          b                  ⍝ Return
      }

    ∇ Z←GetMimeType ext
      :Access public shared
      Z←{
          '.css'≡⍵:'text/css'
          '.ttf'≡⍵:'font/ttf'
          '.png'≡⍵:'image/png'
          '.js'≡⍵:'text/javascript'
          '.html'≡⍵:'text/html'
          '.htm'≡⍵:'text/html'
          '.gif'≡⍵:'image/gif'
          ok←addLogMsg'Error: mime-type not found: ',⍵
          'application/octet-stream'
      }(819⌶)ext
    ∇

    ∇ response←message SendFileResource path;fileType
     
      response←⎕NEW #.H5Message message
     
      fileType←(819⌶)2⊃⎕NPARTS path
      response.MimeType←GetMimeType fileType
      response.Content←GetFileContent path      
      addLogMsg'Resource Path: ',message.RequestPath
    ∇

    fixPath←{('/'@('\'=⊢))⍵}

    ∇ addLogMsg msg
      :Access public instance
      →(~_debug)/0
      ⎕←msg
    ∇

:EndClass
