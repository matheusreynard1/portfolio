function carregarPaginaInicial() {

	document.getElementById('id').value = "";
	document.getElementById('nome').value = "";
	document.getElementById('observacao').value = "";
	document.getElementById('situacao').value = "";
	document.getElementById('listaAtribuicoes').value = "";
	preencherComboBox();
	
}

// Função para preencher a ComboBox de situações
function preencherComboBox() {
    const comboBox = document.getElementById("situacao");

    // Fazer uma solicitação GET para a API
    fetch('http://localhost:6161/situacaoCartorio')
        .then(response => response.json())
        .then(data => {
            // Processar os dados e preencher a ComboBox
            data.forEach(situacao => {
                const option = document.createElement("option");
                option.value = situacao.id; // Defina o valor apropriado
                option.textContent = situacao.nome; // Defina o campo apropriado
                comboBox.appendChild(option);
            });
        })
        .catch(error => {
            console.error('Erro ao buscar dados da API: ' + error);
        });
}

//EXCLUIR CADASTRO //////////////////////////////////////////
function excluirCadastro(idExcluir) {
	
	let id = 0
	id = parseInt(idExcluir);
	
	const url = 'http://localhost:6363/cartorio/delete/' + id; // Substitua com a URL da sua REST API
	
	fetch(url, {
	  method: 'DELETE',
	  headers: {
	    'Content-Type': 'application/json', // Defina os cabeçalhos apropriados conforme necessário
	    // Outros cabeçalhos, como autenticação, podem ser adicionados aqui
	  },
	})
	  .then(response => {
	    if (!response.ok) {
	      throw new Error('Erro ao excluir o recurso. ID 1.'); // Trate erros de acordo com sua lógica
	    }
	    alert("Cadastro excluído com sucesso.");
	    pesquisarCartorios();
	    return response.json(); // Se você espera uma resposta JSON, caso contrário, use response.text()
	  })

}
//////////////////////////////////////////////////////////////////

// SALVAR EDIÇÃO //////////////////////////////////////////
function salvarEdicao() {

if (document.getElementById('nome').value == "" || document.getElementById('nome').value == null) {
	alert('Nome obrigatório.');
} else if (document.getElementById('observacao').value == "" || document.getElementById('observacao').value == null) {
	alert('Observação obrigatória.');
} else if (document.getElementById('situacao').value == "" || document.getElementById('situacao').value == null) {
	alert('Situação cartório obrigatória..');
} else if (document.getElementById('listaAtribuicoes').value == "" || document.getElementById('listaAtribuicoes').value == null) {
	alert('Lista de atribuições obrigatória.');
} else {

	const id =  document.getElementById('id');
	const tbody = gridResultado.querySelector('tbody');
	
    // Obtenha a opção selecionada no comboBox
	const selectElement = document.getElementById("situacao");
    const selectedOption = selectElement.options[selectElement.selectedIndex];
    const selectedText = selectedOption.text;
		
	// Dados que você deseja enviar
	const dadosEdicao = {
	  nome: document.getElementById('nome').value,
	  observacao: document.getElementById('observacao').value,
	  situacao_cartorio: selectedText,
	  lista_atribuicoes: document.getElementById('listaAtribuicoes').value
	};
	
	
	// URL do endpoint 
	const url = "http://localhost:6363/cartorio/alterar/" + id.value; // Substitua pela sua URL real
	
	// Opções da solicitação HTTP
	const options = {
	  method: "PUT", // Use POST para criar um novo cadastro
	  headers: {
	    "Content-Type": "application/json", // Indica que estamos enviando dados em formato JSON
	  },
	  body: JSON.stringify(dadosEdicao), // Converte o objeto JavaScript para JSON
	};
	
	// Faça a solicitação HTTP usando a API Fetch
	fetch(url, options)
	  .then((response) => {
	    if (response.ok) {
	      // A atualização foi bem-sucedida
	      alert('Dados atualizados com sucesso.'); 
	      pesquisarCartorios(); 
	    } else {
	      // A atualização falhou
	      alert('Erro ao atualizar os dados.');
	    }
	  })
	  .catch(error => {
	    alert('Erro na requisição:', error);
	  });
	}
}
//////////////////////////////////////////////////////////////////

// EDITAR CADASTRO //////////////////////////////////////////
function editarCadastro(idEditar) {	
	
mostrarCampos('editarCadastro');

let id = 0
id = parseInt(idEditar);
	
// URL da API Spring Boot que você deseja consumir
const url = "http://localhost:6363/cartorio/" + id
const tbody = gridResultado.querySelector('tbody');

// Faça a solicitação GET usando fetch()
fetch(url)
	.then(response => {
	    if (!response.ok) {
	        throw new Error('Erro ao consumir a API');
	    }
	    response.json().then(data => {
	    	
        // Obtenha a opção selecionada no comboBox
    	const selectElement = document.getElementById("situacao");
        const selectedOption = selectElement.options[selectElement.selectedIndex];
        const selectedText = selectedOption.text;
		
		var textBoxId = document.getElementById('id');
		var textBoxNome = document.getElementById('nome');
		var textBoxObservacao = document.getElementById('observacao');
		var comboBoxSituacaoCartorio = selectedText;
		var textBoxListaAtribuicoes = document.getElementById('listaAtribuicoes');
	
		textBoxId.value = data.cartorioId;
		textBoxNome.value = data.nome;
		textBoxObservacao.value = data.observacao;
		comboBoxSituacaoCartorio.value = data.situacao_cartorio;
		textBoxListaAtribuicoes.value = data.lista_atribuicoes;
	    });
	 })
	.catch(error => {
	    console.error('Erro:', error);
	});
}
//////////////////////////////////////////////////////////////////

// CADASTRAR CARTÓRIO //////////////////////////////////////////
function cadastrarCartorio() {
	
if (document.getElementById('nome').value == "" || document.getElementById('nome').value == null) {
	alert('Nome obrigatório.');
} else if (document.getElementById('situacao').value == "" || document.getElementById('situacao').value == null) {
	alert('Situação do cartório obrigatória.');
} else if (document.getElementById('listaAtribuicoes').value == "" || document.getElementById('listaAtribuicoes').value == null) {
	alert('Listas de atribuições obrigatória.');
} else {
	  
    // Obtenha a opção selecionada no comboBox
	const selectElement = document.getElementById("situacao");
    const selectedOption = selectElement.options[selectElement.selectedIndex];
    const selectedText = selectedOption.text;

	
	// Dados que você deseja enviar no novo cadastro
	const novoCadastro = {
	  nome: document.getElementById('nome').value,
	  observacao: document.getElementById('observacao').value,
	  situacao_cartorio: document.getElementById('situacao').textContent,
	  lista_atribuicoes: document.getElementById('listaAtribuicoes').value,
	  situacao_cartorio: selectedText
	};
	
	
	// URL do endpoint de criação do cadastro no servidor
	const url = "http://localhost:6363/cartorio/cartorioAdd"; // Substitua pela sua URL real
	
	// Opções da solicitação HTTP
	const options = {
	  method: "POST", // Use POST para criar um novo cadastro
	  headers: {
	    "Content-Type": "application/json", // Indica que estamos enviando dados em formato JSON
	  },
	  body: JSON.stringify(novoCadastro), // Converte o objeto JavaScript para JSON
	};
	
	// Faça a solicitação HTTP usando a API Fetch
	fetch(url, options)
	  .then((response) => {
	    if (!response.ok) {
	      throw new Error(`Erro na solicitação: ${response.status}`);
	    }
	    return response.json(); // Converte a resposta JSON em um objeto JavaScript
	  })
	  .then((data) => {
	    // Manipule os dados da resposta aqui, se necessário
	    alert("Cadastro " + data.nome + " criado com sucesso");
	    pesquisarCartorios();
	  })
	  .catch((error) => {
	    alert("Erro ao criar cadastro:", error);
	  });
	}
}
//////////////////////////////////////////////////////////////////

// GET CARTÓRIO POR ID //////////////////////////////////////////
function pesquisarCartorioPorId() {
	
// Pega o ID	
const id = document.getElementById("id").value;
const gridHidden = document.getElementById('gridResultado');

if (id=='0' || id=="") {
	gridHidden.hidden= true;
	alert("Informe um ID válido.");
} else {
	gridHidden.hidden= false;
}

// URL da API Spring Boot que você deseja consumir
const url = "http://localhost:6363/cartorio/" + id
const tbody = gridResultado.querySelector('tbody');

// Faça a solicitação GET usando fetch()
fetch(url)
	.then(response => {
        if (!response.ok) {
            throw new Error('Erro ao consumir a API');
        }
        response.json().then(data => {
		
		tbody.innerHTML = '';

		const id = document.getElementById('id')
		
	    const row = document.createElement('tr');
	        
        row.innerHTML = `
            <td>${data.cartorioId}</td>
            <td>${data.nome}</td>
            <td>${data.observacao}</td>
            <td>${data.situacao_cartorio}</td>
            <td>${data.lista_atribuicoes}</td>
            <td><button type="button"  id="editarBtn"  onclick="editarCadastro(${data.cartorioId})" class="btn btn-secondary">Editar</button></td>
            <td><button type="button"  id="excluirBtn" onclick="excluirCadastro(${data.cartorioId})" class="btn btn-secondary">Excluir</button></td>
        `;
	    tbody.appendChild(row);
        });
     })
    .catch(error => {
        console.error('Erro:', error);
	});
}
//////////////////////////////////////////////////////////////////

// GET TODOS OS CARTÓRIOS ////////////////////////////////////////
function pesquisarCartorios() {
	
	// URL da API Spring Boot que você deseja consumir
	const url = "http://localhost:6363/cartorio";

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
		        
		        row.innerHTML = `
		            <td>${item.cartorioId}</td>
		            <td>${item.nome}</td>
		            <td>${item.observacao}</td>
		            <td>${item.situacao_cartorio}</td>
		            <td>${item.lista_atribuicoes}</td>
		            <td><button type="button"  id="editarBtn"  onclick="editarCadastro(${item.cartorioId})" class="btn btn-secondary">Editar</button></td>
		            <td><button type="button"  id="excluirBtn" onclick="excluirCadastro(${item.cartorioId})" class="btn btn-secondary">Excluir</button></td>
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
		const campo2 = document.getElementById('nome');
		campo2.disabled = false;
		const campo3 = document.getElementById('observacao');
		campo3.disabled = false;
		const campo4 = document.getElementById('situacao'); 
		campo4.disabled = false;
		const campo5 = document.getElementById('listaAtribuicoes');
		campo5.disabled = false;
		
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
		const campo2 = document.getElementById('nome');
		campo2.disabled = true;
		const campo3 = document.getElementById('observacao');
		campo3.disabled = true;
		const campo4 = document.getElementById('situacao');
		campo4.disabled = true;
		const campo5 = document.getElementById('listaAtribuicoes');
		campo5.disabled = true;
		
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
		const campo2 = document.getElementById('nome');
		campo2.disabled = true;
		const campo3 = document.getElementById('observacao');
		campo3.disabled = true;
		const campo4 = document.getElementById('situacao');
		campo4.disabled = true;
		const campo5 = document.getElementById('listaAtribuicoes');
		campo5.disabled = true;
		
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
		const campo2 = document.getElementById('nome');
		campo2.disabled = false;
		const campo3 = document.getElementById('observacao');
		campo3.disabled = false;
		const campo4 = document.getElementById('situacao');
		campo4.disabled = false;
		const campo5 = document.getElementById('listaAtribuicoes');
		campo5.disabled = false;
		
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
