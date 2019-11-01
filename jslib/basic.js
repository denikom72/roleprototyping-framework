//AJAX COMMUNICATION BABEL

	const lnk = "/doLogin";
	
	const sendReq = (link ) => {
	fetch(link, { headers: { "Content-Type": "application/json; charset=utf-8" }})
	    .then(res => res.json()) // parse response as JSON (can be res.text() for plain response)
	    .then(response => {
	        // here you do what you want with response
	    })
	    .catch(err => {
	        console.log("u")
	        alert("sorry, there are no results for your search")
	    }
	);
}

// END BABEL


	// AJAX LYB
	function ajax( type, url, paramstring, callb, onerror ){
		var xmlhttp = window.XMLHttpRequest ?
                        new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
		
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 /* && xmlhttp.status == 200 */)
				var resp = JSON.stringify(xmlhttp.responseText);
			console.log(" JSON-RESPONSE>>>> : " + JSON.stringify(xmlhttp.responseText)); // Here is the response
			if( resp.indexOf("meta") > -1 ){
				document.head.innerHTML += resp;
			}

			//alert(" JSON-RESPONSE" + JSON.stringify(xmlhttp.responseText)); // Here is the response

		}

		xmlhttp.withCredentials = true;
		//xmlhttp.open("POST",getUrlPar , true);
		xmlhttp.open( type , getUrlPar, true);
		//xmlhttp.send("user=" + name + "&password=" + password + "");
		xmlhttp.send(paramstring);
	}

//function ajaxRequest( { reqType, reqUri, queryStr, onSuccess, onError } )
function ajaxRequest( parObj )
{
	var o = parObj;
	//var link = "https://en.wikipedia.org/w/api.php?action=query&prop=info&pageids="+ page +"&format=json&callback=?";
	var xmlHttp = new XMLHttpRequest(); // creates 'ajax' object
        xmlHttp.onreadystatechange = function() //monitors and waits for response from the server
        {
		
		//alert(xmlHttp.status + " : RSTATE : " +  xmlHttp.readyState);
		if(xmlHttp.readyState === 4 ) //checks if response was with status -> "OK"
           	{
        	       if( xmlHttp.status === 200 ){
				//var re = JSON.parse(xmlHttp.responseText); 
		               //if(re["Status"] === "Success")
     				o.onSuccess( xmlHttp.responseText );
			} else {
				
               			o.onError( xmlHttp.responseText );
			}
		}

        }
        //xmlHttp.open("GET", link); //set method and address
	xmlHttp.withCredentials = true;
        xmlHttp.open( o.type, o.uri + "?" + o.query ); 
        xmlHttp.send(); //send data
}

	function sendCred(){
		var bttn = document.getElementById("sendCredenti");
		bttn.addEventListener( "click", (e) => {
			e.preventDefault;
			//alert('BACKEND');
			var xmlhttp = window.XMLHttpRequest ?
				new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
			
			xmlhttp.onreadystatechange = function() {
				if (xmlhttp.readyState == 4 /* && xmlhttp.status == 200 */)
					var resp = JSON.stringify(xmlhttp.responseText);
				console.log(" JSON-RESPONSE>>>> : " + JSON.stringify(xmlhttp.responseText)); // Here is the response
				if( resp.indexOf("meta") > -1 ){
					document.head.innerHTML += resp;
				}
	
					//alert(" JSON-RESPONSE" + JSON.stringify(xmlhttp.responseText)); // Here is the response
			}
			
			var name = document.getElementsByName("uname")[0].value;
			var password = document.getElementsByName('psw')[0].value;
			//make better validator
			if( !name.match(/.+/) || !password.match(/.+/) ){
				alert("User or password empty");
				return;
			}
			//var getUrlPar = "http://timenovestacom/credential/" + name + "/" + password + "";
			var getUrlPar = "http://timenovestacom/credential";
			//console.log("###############################" + getUrlPar);
			alert("SENDING NEW: " +  getUrlPar);
			//xmlhttp.open("GET",getUrlPar , true);
			xmlhttp.open("POST",getUrlPar , true);
			xmlhttp.send("user=" + name + "&password=" + password + "");
	
		});
	};
	
	//HTML LYBRARY
	function toggleView( obj ){
		var expand = '100px', opacity = '0';

		if( obj.offsetWidth <= 240 ){
			expand = '100%';
			opacity = '0.99';
		}

		obj.style.width = expand; 
		obj.style.opacity = opacity;
	
	}

	function toggleOpacity( obj ){
		
	}

	//	
	function say(sentence){
		document.writeln(sentence);
	}
	
	//TODO : Refactoring
	function tag( prop ){
		
		var buildTag = '<' + prop.tn + ' ';

		var k = Object.keys( prop.props );

		k.map(function(v,i){
			buildTag += ' ' + v + '= "' + prop.props[v] + '"';
		});

		buildTag += '>';
		buildTag += prop.tx;
		buildTag += '</' + prop.tn  + '>';
		return buildTag;
	}

	//{ lbTxt : lbTxt, inpProps : inputPropertiesObject, labProps : labelPropertiesObject }
	function InpLabComb( propsObj ){
		//say('<input id="nm" value="" class="inputText" type="text" name="Name" oninput="checkInputLabel(this);" autocomplete="off">')
		//say('<pre>' + JSON.stringify(propsObj) + ' </pre>');	
		var input, label, inp_lab;

		try {
			input =	tag({ 
				tn : 'input',
				tx : propsObj.inpProps.tx,
				props : { 
					class:propsObj.inpProps.props.class,
					id : propsObj.inpProps.props.id,
					oninput:propsObj.inpProps.props.oninput,
					autocomplete:'off',
					type:propsObj.inpProps.props.type,
					value:propsObj.inpProps.props.value || ""
				} 
			} );
			
			label =	tag({ 
				tn : 'label',
				tx : propsObj.labProps.tx,
				props : {
					class : propsObj.labProps.props.classname || 'labelText labelTextDefault',
					id : propsObj.labProps.props.id,
					oninput : 'changeInputLabel(this);'
				}
			} );
		
		} catch( err ) {

		} finally {
			inp_lab = input + label;
		}

		return inp_lab;
	}

	
	//{ lbTxt : lbTxt, inpProps : inputPropertiesObject, labProps : labelPropertiesObject }
	function LabInpComb( propsObj ){
		//say('<input id="nm" value="" class="inputText" type="text" name="Name" oninput="checkInputLabel(this);" autocomplete="off">')
		//say('<pre>' + JSON.stringify(propsObj) + ' </pre>');	
		var input, label, inp_lab;

		try {
			input =	tag({ 
				tn : 'input',
				tx : propsObj.inpProps.tx,
				props : { 
					class:propsObj.inpProps.props.class,
					id : propsObj.inpProps.props.id,
					oninput:propsObj.inpProps.props.oninput,
					autocomplete:'off',
					type:propsObj.inpProps.props.type 
				} 
			} );
			
			label =	tag({ 
				tn : 'label',
				tx : propsObj.labProps.tx,
				props : {
					class : 'labelText labelTextDefault',
					id : propsObj.labProps.props.id,
					oninput : 'changeInputLabel(this);'
				}
			} );
		
		} catch( err ) {

		} finally {
			lab_inp = label + input;
		}

		return lab_inp;
	}


	
	//  
	function chngProps( propsObj ){
		
		var overw = Object.keys( propsObj.overwrite );

		overw.map(function(v, i){

			propsObj.orig[v] = propsObj.overwrite[v];
		});

		return propsObj.orig;
	}
	
	/* WITH THIS 3 FUNCTIONS SAY, TAG AND CHNGPROPS, YOU CAN BUILD MORE COMPLEX TAG-BUILDER */

	var ilPrps = { 
		lbTxt : 'Name', 
		inpProps : { 
				tx : '',
				props : { class:'inputText', oninput:'checkInputLabel(this);', autocomplete:'off', id:'email', type:'text' } 
		},
		labProps : {
				tx : 'NewName',
                                props : { class:'labelText labelTextDefault', oninput:'changeInputLabel(this);', autocomplete:'off', id:'lablEmail' }
		} 
	};
	
	function enabInpLab( attrObj ){
		//say ( JSON.stringify( adptInpLabProbs({ ilProps : ilPrps, overwrite : { tx : 'NewName' } } ) ) );
	
		ilPrps.inpProps = chngProps( { orig : ilPrps.inpProps, overwrite : { tx : '' } } );
		ilPrps.inpProps.props = chngProps( { orig : ilPrps.inpProps.props, overwrite : { id : attrObj.inpId, type : attrObj.inpType } } );
		ilPrps.inpProps.props = chngProps( { orig : ilPrps.inpProps.props, overwrite : { value : attrObj.val } } );
	
		ilPrps.labProps = chngProps( { orig : ilPrps.labProps, overwrite : { tx : attrObj.labText } } );
		ilPrps.labProps.props = chngProps( { orig : ilPrps.labProps.props, overwrite : { id : attrObj.labId } } );
		ilPrps.labProps.props = chngProps( { orig : ilPrps.labProps.props, overwrite : { classname : attrObj.classname } } );
	
		var viewFrag = '<div class="inpLabel">' + InpLabComb( ilPrps ) + '</div>';
		
		return viewFrag;
	}


	function enabLabInp( attrObj ){
		//say ( JSON.stringify( adptInpLabProbs({ ilProps : ilPrps, overwrite : { tx : 'NewName' } } ) ) );
	
		ilPrps.inpProps = chngProps( { orig : ilPrps.inpProps, overwrite : { tx : '' } } );
		ilPrps.inpProps.props = chngProps( { orig : ilPrps.inpProps.props, overwrite : { id : attrObj.inpId, type : attrObj.inpType } } );
	
		ilPrps.labProps = chngProps( { orig : ilPrps.labProps, overwrite : { tx : attrObj.labText } } );
		ilPrps.labProps.props = chngProps( { orig : ilPrps.labProps.props, overwrite : { id : attrObj.labId } } );
	
		var viewFrag = '<div class="labelInp">' + LabInpComb( ilPrps ) + '</div>';
		
		return viewFrag;
	}

	function button1( propObj ){
		var oncl = "";
		try{
			oncl = propObj.onclick;
		} catch( err ){
			console.log( err );
		}

		return '<div class="mybtn" style=' + propObj.wrappStyle + '>' + tag( { tn: 'input', tx:'', props : { type : 'button', id : propObj.id, value : propObj.value, style : propObj.style, onclick : oncl } } ) + '</div>';	
	}

	function option1( propObj ){
		
		var option = "";

		propObj.optList.map( function( v,i ){
			var val = v;
			if( parseInt(i) == 0 ){
				val = '';
			}

			var prps = val == propObj.selectedVal ? { value:val, style:'font-size: 17px;' } : { value:val, selected:'true', style:'font-size: 17px;' };
			option += tag( { tn: 'option', tx:v, props : prps } );
		});

		return '<div class="mybtn" style=' + propObj.wrappStyle + '>' + tag( { tn: 'select', tx:option, props : { id : propObj.id, style : propObj.style, class : propObj.class } } ) + '</div>';	
	}
	
	function labl(){

		say('<label class="labelText labelTextDefault" oninput="changeInputLabel(this);">Name</label>') 
	}


	function collectData( doc ){
		try {
			if( doc && doc != "" ){
				document = doc;
			}
		} catch( err ){
			console.log( err );
		}

		var data = "";
		var inps = document.getElementsByTagName('input');
		
		[].forEach.call( inps, function( v, i ){
			if( ( v.type == "text" || v.type == "password" ) && v.value != "" ){
				data += v.id + "=" + v.value + "&";
			}
		});

		var sel = document.getElementsByTagName('select');
		
		[].forEach.call( sel, function( v, i ){
			if( v.options[ v.selectedIndex ].value != "" ){
				data += v.id + "=" + v.options[ v.selectedIndex ].value + "&" ;
			}

		});

		data = data.replace(/&$/, "");
		return data;
	}
	
	
	/******* END HTML-LYB ***********/

	function checkInputLabel(obj) {
	        var myLabel = obj.parentNode.getElementsByClassName('labelText')[0];
	
	        
	        if(obj.value) {
	                myLabel.classList.remove('labelTextDefault');
	                myLabel.classList.add('labelTextUp');
	                        console.log(obj);
	
	        } else {
	                myLabel.classList.remove('labelTextUp');
	                myLabel.classList.add('labelTextDefault');
	        }
	}
	
	function changeInputLabel(obj) {
	        obj.classList.remove('labelTextDefault');
	        obj.classList.add('labelTextUp');
	        var ths = obj.parentNode.getElementsByClassName('inputText')[0];
	        ths.focus();
	        //ths.style.borderColor = "yellow";
	        
	}

	[].forEach.call( document.getElementsByClassName('inputText'), function(v,i) {

		checkInputLabel(v);		

	} );
