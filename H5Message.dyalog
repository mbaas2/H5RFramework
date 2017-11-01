:class H5Message
:access public

    :field private _ob
    :field private _event ←'HTTPRequest'
    :field private _const ←'ProcessRequest'
    :field private _updated ←0
    :field private _statuscode ←200
    :field private _statusmsg      ←'OK'
    :field private _mime       ←'text/html'
    :field private _headers  ← ⍬
    :field private _body       ←''
    :field private _url        ←''
    :field private _domainRoot←'http://dyalog_root'
    :field private _method ←''

    :Property ObjectRef
    :access public instance
        ∇ r←get
          r←_ob
        ∇

        ∇ set args
          _ob←args.NewValue
        ∇
    :EndProperty

    :Property IsUpdated
    :access public instance

        ∇ r←get
          r←_updated
        ∇

        ∇ set args
          _updated←args.NewValue
        ∇
    :EndProperty

    :Property StatusCode
    :access public instance

        ∇ r←get
          r←_statuscode
        ∇

        ∇ set args
          _statuscode←args.NewValue
        ∇
    :EndProperty

    :Property StatusMessage
    :access public instance

        ∇ r←get
          r←_statusmsg
        ∇

        ∇ set args
          _statusmsg←args.NewValue
        ∇
    :EndProperty

    :Property MimeType
    :access public instance
        ∇ r←get
          r←_mime
        ∇

        ∇ set args
          _mime←args.NewValue
        ∇
    :EndProperty

    :Property Headers
    :access public instance

        ∇ r←get
          :If 0=≢_headers
              r←'Content-Type: ',_mime,⎕UCS 13 10
          :Else
              stop
          :EndIf
        ∇

        ∇ set args
          _headers←args.NewValue
        ∇
    :EndProperty

    :Property URL
    :access public instance

        ∇ r←get
          r←_url
        ∇

        ∇ set args
          _url←args.NewValue
        ∇
    :EndProperty

    :Property Content
    :access public instance

        ∇ r←get
          r←_body
        ∇

        ∇ set args
          _body←args.NewValue 
          _updated←1
        ∇
    :EndProperty

    :property IsValidDomain
    :access public instance
        ∇ r←get
          r←_domainRoot≡(≢_domainRoot)↑_url
        ∇
    :endproperty

    :property RequestDomain
    :access public instance
        ∇ r←get
          r←0⊃⎕NPARTS _url
        ∇
    :endproperty

    :property RequestPath
    :access public instance
        ∇ r←get
          r←(≢_domainRoot)↓_url
          :If '/'=¯1↑r
              r←¯1↓r
          :EndIf
        ∇
    :endproperty

    :property RequestPathVec
    :access public instance
        ∇ r←get
          r←{(⍵≠'/')⊆⍵}RequestPath
        ∇
    :endproperty

    :property Method
    :access public instance
        ∇ r←get
          r←(0≠≢_body)⊃'GET' 'POST'
        ∇
    :endproperty
    ∇ const1 obRef
      :Access public
      :Implements constructor
      _ob←obRef.ObjectRef
      _url←obRef.URL
    ∇

    ∇ const2(ob event const1 updated statuscode statusmsg mime url headers body)
      :Access public
      :Implements constructor
      _ob←ob
      _updated←updated
      _statuscode←statuscode
      _statusmsg←statusmsg
      _mime←mime
      _url←url
      _headers←headers
      _body←body
    ∇

    ∇ Z←ToHTMLRenderer
      :Access public instance
      Z←(_ob _event _const _updated _statuscode _statusmsg _mime _url Headers _body)
    ∇
:endclass
