:Namespace FmtBuilder

⍝ API Callback for analyzing format string properties.  
⍝ The properties are submitted through JSON objects via POST

      getFmtIntitial←{
          r←⎕NEW #.H5Message ⍺
          time←{('-'@(' '=⊢))⍕3↑¯4↑⎕TS}
          j←json_initialStateResponse''
          j.form_title,←'  ',time''
          j.form_description,←' ',time''
          j.format←json_formatProperties''
          j.data←{⍵[⍋⍵]}0,(((10⍴¯1),10⍴1)×?20⍴10000){⍺×⍵}?20⍴0
          r.MimeType←'appllication/json'
          r.Content←⎕JSON j
          r
      }

      getPostResponse←{
          r←⎕NEW #.H5Message ⍺
     
          11::r{
              ⍺.StatusCode←400
              ⍺.StatusMessage←⎕DMX.Message
              ⍺
          }''
     
          jsonReq←⎕JSON ⍺.Content
     
          action←(819⌶)jsonReq.action_type~' '
     
          action≡'test':r testFormatString jsonReq.action_request
     
          action≡'cancel':resp{
              ok←#.addLogMsg'Closing HTMLRenderer'
              obj.Close
              ⍺.ToHtmlRenderer
          }''
     
          action≡'ok':resp{
     
              ok←#.addLogMsg'Save format and close HTMLRenderer.'
              obj.Close
          }jsonReq.action_request
     
          resp.HttpStatus←400
          resp.HttpStatusText←'Invalid action.. if gethelp not impelmemented'
          resp.ToHtmlRenderer
     
      }         
      
      testFormatString  ←{      
              ⍺.Content←⎕JSON procRequest ⍵
              ⍺.StatusCode←200
              ⍺.MimeType←'appllication/json'
              ⍺
          }

      json_formatProperties←{
          j←⎕NS''
          j.field_width←8
          j.decimal_count←2
          j.insert_commas←⊂'false'
          j.left_justify←⊂'false'
          j.zero_blank←⊂'false'
          j.zero_fill←⊂'false'
          j.decimal_scale←0
          j.prefix_negative←''
          j.prefix_positive←''
          j.suffix_negative←''
          j.suffix_positive←''
          j.decimal_separator←'.'
          j.thousands_separator←','
          j.replace_number←⍬
          j
      }


      json_formatted_data←{
          j←⎕NS''
          j.(formatted_data original_data)←⍵
          j
      }

      json_replaceNumberProperty←{
          j←⎕NS''
          j.from←0
          j.to←''
          j
      }

      json_initialStateResponse←{
          j←⎕NS''
          j.form_title←'Format String Builder.'
          j.form_description←'Format strings are used to specify how numbers should appear on reports and exports.\n\nSelect from the options below...'
          j.format←⊂'null'
          j.data←⍬
          j
      }

      json_postResponse←{
          j←⎕NS''
          j.format_string←''
          j.is_valid_format←⊂'false'
          j.format←⊂'null'
          j.respose_data←⍬
          j.error_details←⊂'null'
          j
      }

      procRequest←{
          j←⍵
          f←j.format
          r←json_postResponse''
          r.format←f
     
          isError←2=+/(↑¨f.(left_justify zero_fill))∊⊂'true'  ⍝ check if ljust and zero fill mutually exclusive
          isError:r errorLeftJustZeroFill''
          0::r{r.error_details←⍵ ⋄ r}⎕DMX
     
          fmt←f.field_width{d←⍵≠0 ⋄ 'IF'[d],(⍕⍺),d⊃''('.',⍕⍵)}f.decimal_count
          fmt←((f.insert_commas≡⊂'true')⊃'' 'C'),fmt
          fmt←((f.left_justify≡⊂'true')⊃'' 'L'),fmt
          fmt←((f.zero_fill≡⊂'true')⊃'' 'Z'),fmt
          fmt←({⍵=0:'' ⋄ 'K',⍕⍵}f.decimal_scale),fmt
          fmt←((f.zero_blank≡⊂'true')⊃'' 'B'),fmt
     
          enc←{0=≢⍺:1⊃⍵ ⋄ (0⊃⍵),'<',⍺,'>',1⊃⍵}
     
          fmt←f.suffix_positive enc'Q'fmt
          fmt←f.prefix_positive enc'P'fmt
          fmt←f.suffix_negative enc'N'fmt
          fmt←f.prefix_negative enc'M'fmt
     
          sepReplace←∊{
              0=≢⍵:''
              {0=≢⍵.to:'' ⋄ 'O',(⍕⍵.from),'<',⍵.to,'>'}¨⍵
          }f.replace_number
     
          fmt←sepReplace,fmt
     
          sepReplace←{
              ⍵.insert_commas≡⊂'false':''
              0=≢⍵.thousands_separator:''
              sep←⍕↑⍵.thousands_separator
              ','≡sep:''
              ',',sep
          }f
     
          sepReplace,←{
              0=≢⍵.decimal_separator:''
              sep←⍕↑⍵.decimal_separator
              '.'≡sep:''
              '.',sep
          }f
     
          fmt←sepReplace{0=≢⍺:⍵ ⋄ 'S<',⍺,'>',⍵}fmt
     
          r.format_string←fmt
     
          ⍝ format result negatives to be normal not high minus.
          ⍝ do not display as part of the format string.
          fmt←f.prefix_negative{0≠≢⍺:⍵ ⋄ 'M<->',⍵}fmt
     
          7::r       ⍝ format error
          displayValues←↓fmt ⎕FMT j.data
          r.respose_data←json_formatted_data¨↓⍉⊃displayValues j.data
     
          r.is_valid_format←⊂'true'
          r
      }

      sampleDataArray←{
          (-0.123 1 10.123 100 10000.12 100000),0 0.123 1 10.123 100 10000.12 100000
      }

      errorLeftJustZeroFill←{
          err←dmxNS''
          err.EN←6
          err.Message←'Cannot left justify and zero fill at the same time.'
          ⍺.error_details←err
          ⍺
      }

      test_request←{
          j←⎕NS''
          j.format←json_formatProperties''
          j.format.replace_number,←json_replaceNumberProperty''
          j.format.replace_number,←json_replaceNumberProperty''
          j.format.replace_number.from←0 ¯999
          j.format.replace_number.to←'N/A' 'Error'
          j.data←sampleDataArray''
          json←⎕JSON j
          json
      }

      dmxNS←{
          ns←⎕NS''
          ns.Category←''
          ns.DM←⍬
          ns.EM←''
          ns.EN←0
          ns.ENX←0
          ns.HelpURL←''
          ns.InternalLocation←⍬
          ns.Message←''
          ns.OSError←0 0 ''
          ns.Vendor←''
          ns
      }

:EndNamespace
