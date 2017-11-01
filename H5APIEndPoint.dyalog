:Class H5APIEndPoint

    :field private _path ← ⎕null
    :field private _GET  ← ⎕null
    :field private _POST ← ⎕null

    :Property Path
    :access public instance
        ∇ r←get
          r←_path
        ∇

        ∇ set args
          _path←args.NewValue
        ∇
    :EndProperty         
    
    :Property PathVec
    :access public instance
        ∇ r←get
          r←{(⍵≠'/')⊆⍵}_path
        ∇
    :EndProperty

    :Property GET
    :access public instance
        ∇ r←get
          r←_GET
        ∇

        ∇ set args
          _GET←args.NewValue
        ∇
    :EndProperty

    :Property POST
    :access public instance
        ∇ r←get
          r←_POST
        ∇

        ∇ set args
          _POST←args.NewValue
        ∇
    :EndProperty


:EndClass
