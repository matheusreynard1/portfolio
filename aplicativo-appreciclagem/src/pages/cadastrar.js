import React, { useState, useContext } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, ScrollView } from 'react-native';
import axios from 'axios'; 

export default function TelaCadastrar() {

  const [nome, setNome] = useState('');
  const [senha, setSenha] = useState('');
  const [email, setEmail] = useState('');
  const [telefone, setTelefone] = useState('');
  const [endereco, setEndereco] = useState('');

  const dadosFormulario = {
    nome: nome,
    senha: senha,
    email: email,
    telefone: telefone,
    endereco: endereco
  };

  async function clicouCadastrar() {
    if (nome === '' || nome === undefined) {
      alert('Nome é obrigatório.');
    } else if (senha === '' || senha === undefined) {
      alert('Senha é obrigatória.');
    } else if (email === '' || email === undefined) {
      alert('E-mail é obrigatório.');
    } else if (telefone === '' || telefone === undefined) {
      alert('Telefone é obrigatório.');
    } else if (endereco === '' || endereco === undefined) {
      alert('Endereço é obrigatório.');
    } else {
        // CHECA SE JÁ EXISTE O NOME CADASTRADO NO BANCO DE DADOS, SE NÃO HOUVER, O CADASTRO É EFETUADO
        try {
          const response = await axios.get('http://10.0.2.2:6565/empresa/nomeExistente/' + nome);
          if (response.data.length > 0 && response.data !== null) {
            alert('Este nome já está cadastrado!')
          } else {
            await axios.post('http://10.0.2.2:6565/empresa/empresaAdd', dadosFormulario)
            alert('Cadastro realizado com sucesso!!');
          }
        } catch (error) {
          console.error('Erro na requisição', error)
        }
      }
    }

  return (
    <ScrollView style={styles.container} contentContainerStyle={{justifyContent: 'center', alignItems: 'center'}}>

      <Text style={{color: "black", fontSize: 15, paddingBottom: 30}}>Informe os dados abaixo para realizar seu cadastro.</Text>

      <TextInput
        name="nome"
        style={styles.input}
        placeholder="Nome"
        value={nome}
        onChangeText={setNome}
      />

      <TextInput
        name="senha"
        style={styles.input}
        placeholder="Senha"
        value={senha}
        onChangeText={setSenha}
        secureTextEntry
      />

      <TextInput
        name="email"
        style={styles.input}
        placeholder="E-mail"
        value={email}
        onChangeText={setEmail}
      />

      <TextInput
        name="telefone"
        style={styles.input}
        placeholder="Telefone"
        value={telefone}
        onChangeText={setTelefone}
      />

      <TextInput
        name="endereco"
        style={styles.input}
        placeholder="Endereço"
        value={endereco}
        onChangeText={setEndereco}
      />

      <View style={styles.buttonContainer}>
        <TouchableOpacity onPress={clicouCadastrar} style={styles.button}>
          <Text style={{ color: '#FFF' }}>CADASTRAR</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

// STYLE SHEETS
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
    paddingTop: 100
  },
  input: {
    height: 40,
    borderColor: 'gray',
    borderWidth: 1,
    margin: 10,
    padding: 10,
    width: '85%',
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '85%',
    alignItems: 'center',
    paddingTop: 30,
  },
  button: {
    flex: 1,
    alignItems: 'center',
    backgroundColor: '#6C813C',
    padding: 10,
    margin: 10,
    borderTopLeftRadius: 15,
    borderTopRightRadius: 15,
    borderBottomRightRadius: 15,
    borderBottomLeftRadius: 15,
  }
});