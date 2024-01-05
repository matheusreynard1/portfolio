function carregarPaginaInicial() {

	document.getElementById('id').value = ""
	document.getElementById('situacao').value = ""
	document.getElementById('observacao').value = ""
	
}

//EXCLUIR CADASTRO //////////////////////////////////////////
function excluirCadastro(idExcluir, nomeVerificar) {
	
	let id = 0;
	if (idExcluir) {
	  id = parseInt(idExcluir);
	}
	
	const urlExcluir = 'http://localhost:6161/situacaoCartorio/delete/' + id; // Substitua com a URL da sua REST API
	const urlVerificarExistencia = 'http://localhost:6363/cartorio/verificarExistencia/' + nomeVerificar;
	  
	  
	// Faça a solicitação GET usando fetch()
	fetch(urlVerificarExistencia)
	.then(response => {
	    if (!response.ok) {
	        throw new Error('Erro ao consumir a API');
	    }
	    response.json().then(data => {
	        if (data !== 0) {
	          alert("Impossível continuar pois a situação está vinculada com um cartório.");
	        }
	        else if (data === 0) {
	        	fetch(urlExcluir, {
	    		  method: 'DELETE',
	    		  headers: {
	    		    'Content-Type': 'application/json', // Defina os cabeçalhos apropriados conforme necessário
	    		    // Outros cabeçalhos, como autenticação, podem ser adicionados aqui
	    		  },
	    		})
	    		  .then(response => {
	    		    if (!response.ok) {
	    		      throw new Error('Erro ao excluir o recurso.'); // Trate erros de acordo com sua lógica
	    		    }
	    		    alert("Cadastro excluído com sucesso.");
	    		    pesquisarSituacoes();
	    		    return response.json(); // Se você espera uma resposta JSON, caso contrário, use response.text()
	    		  })
	        }
      })
      .catch(error => {
        console.error('Erro:', error);
      });
	})
}
//////////////////////////////////////////////////////////////////

// SALVAR EDIÇÃO /////////////////////////////////////////
function salvarEdicao() {

	if (document.getElementById('situacao').value == "" || document.getElementById('situacao').value == null) {
		alert('Nome obrigatório.');
	} else if (document.getElementById('id').value == "" || document.getElementById('id').value == null) {
		alert('ID obrigatório.');
	} else {

	const id =  document.getElementById('id');
	
	// Dados que você deseja enviar no novo cadastro
	const dadosEdicao = {
	  nome: document.getElementById('situacao').value,
	  observacao: document.getElementById('observacao').value
	};
	
	// URL do endpoint 
	const url = "http://localhost:6161/situacaoCartorio/alterar/" + id.value; // Substitua pela sua URL real
	const urlAtualizarNome = "http://localhost:6363/cartorio/atualizarCartorio/" + document.getElementById('situacao').value;
	
	// Opções da solicitação HTTP
	const options = {
	  method: "PUT", // Use POST para criar um novo cadastro
	  headers: {
	    "Content-Type": "application/json", // Indica que estamos enviando dados em formato JSON
	  }
	};
	
	// Faça a solicitação HTTP usando a API Fetch
	fetch(urlAtualizarNome, options)
	  .then((response) => {
	    if (response.ok) {
	    	console.log("Atualizou na tabela cadastro_cartorio");
	    } else {
	      // A atualização falhou
	      alert('Erro ao atualizar os dados.');
	    }
	  })
	  .catch(error => {
	    alert('Erro na requisição:', error);
	  });
	
	// Opções da solicitação HTTP
	const options2 = {
	  method: "PUT", // Use POST para criar um novo cadastro
	  headers: {
	    "Content-Type": "application/json", // Indica que estamos enviando dados em formato JSON
	  },
	  body: JSON.stringify(dadosEdicao), // Converte o objeto JavaScript para JSON
	};
	
	// Faça a solicitação HTTP usando a API Fetch
	fetch(url, options2)
	  .then((response) => {
	    if (response.ok) {
	      // A atualização foi bem-sucedida
	      alert('Dados atualizados com sucesso.');  
	      pesquisarSituacoes();
	    } else {
	      // A atualização falhou
	      alert('Erro ao atualizar os dados.');
	    }
	  })
	  .catch(error => {
	    alert('Erro na requisição:', error);
	  });
	};
}

//GET CARTÓRIO POR ID //////////////////////////////////////////
function pesquisarSituacaoPorId() {
	
	//Pega o ID	
	const id = document.getElementById("id").value;
	const gridHidden = document.getElementById('gridResultado');
	
	if (id=='0' || id=="") {
		gridHidden.hidden= true;
		alert("Informe um ID válido.");
	} else {
		gridHidden.hidden= false;
	}
	
	//URL da API Spring Boot que você deseja consumir
	const url = "http://localhost:6161/situacaoCartorio/" + id
	const tbody = gridResultado.querySelector('tbody');
	
	//Faça a solicitação GET usando fetch()
	fetch(url)
		.then(response => {
	     if (!response.ok) {
	         throw new Error('Erro ao consumir a API');
	     }
	     response.json().then(data => {
			
		tbody.innerHTML = '';	
		let verificarNome = item.nome;
	    const row = document.createElement('tr');
	    
	     row.innerHTML = `
	         <td>${data.id}</td>
	         <td>${data.nome}</td>
	         <td>${data.observacao}</td>
	         <td><button type="button"  id="editarBtn"  onclick="editarCadastro(${data.id}, '${verificarNome}')" class="btn btn-secondary">Editar</button></td>
	         <td><button type="button"  id="excluirBtn" onclick="excluirCadastro(${data.id}, '${verificarNome}')" class="btn btn-secondary">Excluir</button></td>
	     `;
		    tbody.appendChild(row);
	     });
	  })
	 .catch(error => {
	     console.error('Erro:', error);
	  });	
}

//////////////////////////////////////////////////////////////////

// EDITAR CADASTRO //////////////////////////////////////////
function editarCadastro(idEditar, nomeVerificar) {	
	
	console.log(nomeVerificar);

	mostrarCampos('editarCadastro');

	let id = 0;
	if (idEditar) {
	  id = parseInt(idEditar);
	}

	const urlVerificarExistencia = 'http://localhost:6363/cartorio/verificarExistencia/' + nomeVerificar;
	const urlAtualizar = "http://localhost:6161/situacaoCartorio/" + id;  
	  
	// Faça a solicitação GET usando fetch()
	fetch(urlVerificarExistencia)
	.then(response => {
	    if (!response.ok) {
	        throw new Error('Erro ao consumir a API');
	    }
	    response.json().then(data => {
	    	console.log(data)
	        if (data !== 0) {
	            alert("Impossível continuar pois a situação está vinculada com um cartório.");
	        } else if (data === 0) {
	          	fetch(urlAtualizar)
	          	.then(response => {
	          	    if (!response.ok) {
	          	        throw new Error('Erro ao consumir a API');
	          	    }
	          	    response.json().then(data => {
	          		
	          		var textBoxId = document.getElementById('id');
	          		var textBoxSituacao = document.getElementById('situacao');
	          		var textBoxObs = document.getElementById('observacao');
	          	
	          		textBoxId.value = data.id;
	          		textBoxSituacao.value = data.nome;
	          		textBoxObs.value = data.observacao;
	          	    });
	          	 })
	          	.catch(error => {
	          	    console.error('Erro:', error);
	          	});
	        }
	  })
	  .catch(error => {
	    console.error('Erro:', error);
	  });
	})

}
//////////////////////////////////////////////////////////////////

// CADASTRAR SITUAÇÃO //////////////////////////////////////////
function cadastrarSituacao() {
	  if (document.getElementById('situacao').value == "" || document.getElementById('situacao').value == null) {
	    alert('Nome obrigatório.');
	  } else {
	    const novoCadastro = {
	      nome: document.getElementById('situacao').value,
	      observacao: document.getElementById('observacao').value
	    };

	    const urlVerificarNome = "http://localhost:6161/situacaoCartorio/verificarNome/" + document.getElementById('situacao').value;
	    const urlCadastrar = "http://localhost:6161/situacaoCartorio/situacaoCartorioAdd";

	    // Faça a solicitação GET usando fetch()
	    fetch(urlVerificarNome)
	      .then(response => {
	        if (!response.ok) {
	          throw new Error(`Erro na solicitação GET: ${response.status} - ${response.statusText}`);
	        }
	        return response.json(); // Retornar a resposta JSON
	      })
	      .then(data => {
	        if (data.situacaoCartorioId !== 0) {
	          alert("Impossível continuar pois o nome da situação já existe.");
	        }
	        else if (data.situacaoCartorioId === 0) {
	          // Agora, aninhamos o próximo bloco .then aqui
	          const options = {
	            method: "POST",
	            headers: {
	              "Content-Type": "application/json",
	            },
	            body: JSON.stringify(novoCadastro),
	          };
	          fetch(urlCadastrar, options)
	            .then(response => {
	              if (!response.ok) {
	                throw new Error(`Erro na solicitação POST: ${response.status} - ${response.statusText}`);
	              }
	              return response.json();
	            })
	            .then(data => {
	              alert("Cadastro criado com sucesso");
	              pesquisarSituacoes();
	            })
	            .catch(error => {
	              console.log("Erro ao criar cadastro:", error);
	            });
	        }
	      })
	      .catch(error => {
	        console.error('Erro:', error);
	      });
	  }
	}
//////////////////////////////////////////////////////////////////


// GET TODAS AS SITUAÇÕES ////////////////////////////////////////
function pesquisarSituacoes() {
	
// URL da API Spring Boot que você deseja consumir
const url = "http://localhost:6161/situacaoCartorio";

const tbody = gridResultado.querySelector('tbody');

const gridHidden = document.getElementById('gridResultado');
gridHidden.hidden= false;

// Faça a solicitação GET usando fetch()
fetch(url)
	.then(response => {
        if (!response.ok) {
            throw new Error('Erro ao consumir a API');
        }
        response.json().then(data => {
			
		tbody.innerHTML = '';
		
        // Manipule os dados da API aqui
        data.forEach(item => {
	        const row = document.createElement('tr');
	        let verificarNome = item.nome;
	        
	        row.innerHTML = `
	            <td>${item.id}</td>
            	<td>${item.nome}</td>
            	<td>${item.observacao}</td>
	            <td><button type="button"  id="editarBtn"  onclick="editarCadastro(${item.id}, '${verificarNome})'" class="btn btn-secondary">Editar</button></td>
	            <td><button type="button"  id="excluirBtn" onclick="excluirCadastro(${item.id}, '${verificarNome}')" class="btn btn-secondary">Excluir</button></td>
	        `;
	        tbody.appendChild(row);
        });
    })
    .catch(error => {
        console.error('Erro:', error);
    });
  })
};
//////////////////////////////////////////////////////////////////

function mostrarCampos(formulario) {
	
	if (formulario=='cadastrar') {
		const campo = document.getElementById('id');
		campo.disabled = true;
		const campo2 = document.getElementById('situacao');
		campo2.disabled = false;
		const campo3 = document.getElementById('observacao');
		campo3.disabled = false;
		
		const botao = document.getElementById('cadastrarBtn');
		botao.hidden = false;
		const botao2 = document.getElementById('pesquisarTodosBtn');
		botao2.hidden = true;
		const botao3 = document.getElementById('pesquisarIdBtn');
		botao3.hidden = true;
		const botao4 = document.getElementById('salvarEdicaoBtn');
		botao4.hidden = true;		
	}
	
	if (formulario=='pesquisarTodos') {
		const campo = document.getElementById('id');
		campo.disabled = true;
		const campo2 = document.getElementById('situacao');
		campo2.disabled = true;
		const campo3 = document.getElementById('observacao');
		campo3.disabled = true;
		
		const botao = document.getElementById('cadastrarBtn');
		botao.hidden = true;
		const botao2 = document.getElementById('pesquisarTodosBtn');
		botao2.hidden = false;
		const botao3 = document.getElementById('pesquisarIdBtn');
		botao3.hidden = true;
		const botao4 = document.getElementById('salvarEdicaoBtn');
		botao4.hidden = true;
	}
	
	if (formulario=='pesquisarPorId') {
		const campo = document.getElementById('id');
		campo.disabled = false;
		const campo2 = document.getElementById('situacao');
		campo2.disabled = true;
		const campo3 = document.getElementById('observacao');
		campo3.disabled = true;
		
		const botao = document.getElementById('cadastrarBtn');
		botao.hidden = true;
		const botao2 = document.getElementById('pesquisarTodosBtn');
		botao2.hidden = true;
		const botao3 = document.getElementById('pesquisarIdBtn');
		botao3.hidden = false;
		const botao4 = document.getElementById('salvarEdicaoBtn');
		botao4.hidden = true;
	}
	
	if (formulario=='editarCadastro') {
		const campo = document.getElementById('id');
		campo.disabled = true;
		const campo2 = document.getElementById('situacao');
		campo2.disabled = false;
		const campo3 = document.getElementById('observacao');
		campo3.disabled = false;
		
		const botao = document.getElementById('cadastrarBtn');
		botao.hidden = true;
		const botao2 = document.getElementById('pesquisarTodosBtn');
		botao2.hidden = true;
		const botao3 = document.getElementById('pesquisarIdBtn');
		botao3.hidden = true;
		const botao4 = document.getElementById('salvarEdicaoBtn');
		botao4.hidden = false;
	}
}