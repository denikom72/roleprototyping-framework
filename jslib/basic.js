	//function ajaxRequest( { reqType, reqUri, queryStr, onSuccess, onError } )
	function ajaxRequest( parObj )
	{
		var o = parObj;
		//var link = "https://en.wikipedia.org/w/api.php?action=query&prop=info&pageids="+ page +"&format=json&callback=?";
		var xmlHttp = new XMLHttpRequest(); 
	        xmlHttp.onreadystatechange = function() //monitors and waits for response from the server
	        {
			
			//alert(xmlHttp.status + " : RSTATE : " +  xmlHttp.readyState);
			if(xmlHttp.readyState === 4 ) //response has status -> "OK"
	           	{
	        	       if( xmlHttp.status === 200 ){
	     				o.onSuccess( xmlHttp.responseText );
				} else {
					
	               			o.onError( xmlHttp.responseText );
				}
			}
	
	        }
	        //xmlHttp.open("GET", link); 
		xmlHttp.withCredentials = true;
	        xmlHttp.open( o.type, o.uri + "?" + o.query ); 
	        xmlHttp.send(); 
	}

	
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
	
	/* THIS 3 FUNCTIONS ( SAY, TAG AND CHNGPROPS ) CAN BE USED FOR BUILDING MORE COMPLEX TAG-BUILDER */

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

			option += tag( { tn: 'option', tx:v, props : { value:val, style:'font-size: 17px;' } } );
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
	        
	}

	[].forEach.call( document.getElementsByClassName('inputText'), function(v,i) {

		checkInputLabel(v);		

	} );
