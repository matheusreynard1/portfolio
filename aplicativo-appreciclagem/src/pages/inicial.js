import { View, Text, StyleSheet, FlatList, TextInput, TouchableOpacity, ScrollView} from 'react-native'
import React, { useContext, useState, Component, useEffect} from 'react';
import { useNavigation } from '@react-navigation/native'
import { AuthContext } from '../contexts/authContext';
import axios from 'axios'; 

export default function TelaInicial() {

  const { user } = useContext(AuthContext)
  const { setAuthState } = useContext(AuthContext);
  const { tokenRecebido } = useContext(AuthContext);
  const navigation = useNavigation();
  const [data, setData] = useState([]);
  const [pesquisarNome, setPesquisarNome] = useState();

  function clicouDeslogar() {
    // Aqui você pode realizar a lógica desejada com os dados do formulário
      setAuthState(false);
      navigation.navigate('Nome')
  }

  async function clicouPesquisar() {
    const token = tokenRecebido;
    console.log('clicou pesquisar: ' + token)

    if (pesquisarNome !== '' && pesquisarNome !== undefined) {

      // ENDPOINT DE BUSCAR PELO NOME DA EMPRESA
      const resposta = await axios.get('http://10.0.2.2:6565/empresa/buscarNome/' + pesquisarNome, {
        headers: {
          'Authorization': `${token}`
        },
      })
      .then(response => { 
        setData(response.data);
      }).catch((error) => { 
        console.log(error + ' - Error retrieving data endpoint /empresa/buscarNome')
      })

    } else {

      // ENDPOINT DE BUSCAR TODAS AS EMPRESAS
      const resposta2 = await axios.get('http://10.0.2.2:6565/empresa', {
        headers: {
          'Authorization': `${token}`
        },
      })
      .then(response => { 
        setData(response.data);
      }).catch((error) => { 
        console.log(error + ' - Error retrieving data endpoint /empresa')
      })
    }
  };

  return(
    <ScrollView style={styles.container} contentContainerStyle={{justifyContent: 'center', alignItems: 'center'}}>
      <View style={styles.containerTitle}>
        <Text style={{color: "white"}}>Bem Vindo(a)</Text>
        <Text style={styles.title}>{user.nome}</Text>
      </View>
      <View style={styles.containerPesquisar}>
        <TextInput
          placeholder="Pesquisar por Nome..."
          style={{ borderBottomWidth: 1, borderBottomColor: '#ccc' , width: 330 }}
          value={pesquisarNome}
          onChangeText={setPesquisarNome}
        />
      </View>
      <View style={styles.containerFlatlist}>
        <FlatList
          data={data}
          keyExtractor={(item) => item.idEmpresa}
          renderItem={({ item }) => (
            <View style={{ width: 320 }}>
              <Text style={styles.textItem}>{item.nome} - {item.endereco}</Text>
            </View>
          )}
          ListHeaderComponent={() => (
            <View>
              <Text>NOME - ENDEREÇO</Text>
            </View>
          )}
        />
      </View>
      <View style={styles.buttonContainer}>
        <TouchableOpacity onPress={clicouPesquisar} style={styles.button}>
          <Text style={{ color: "#FFF", fontSize: 12}}>PESQUISAR</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.button}>
          <Text style={{ color: "#FFF", fontSize: 12}}>BUSCAR EMPRESA MAIS PRÓXIMA</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={clicouDeslogar} style={styles.button}>
          <Text style={{ color: "#FFF", fontSize: 12}}>DESLOGAR</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  )
}

// STYLE SHEETS
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "white"
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: "white"
  },
  containerTitle: {
    backgroundColor: "#6C813C",
    justifyContent: 'center',
    alignItems: 'center',
    paddingLeft: 20,
    paddingRight: 20,
    height: 60,
    width: 350,
    borderBottomRightRadius: 15,
    borderBottomLeftRadius: 15
  },
  containerPesquisar: {
    flex: 0.15,
    backgroundColor: "white",
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1, 
    borderColor: '#000', 
    margin: 10, 
    borderRadius: 5
  },
  containerFlatlist: {
    flex: 1,
    backgroundColor: "white",
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1, 
    borderColor: '#000', 
    margin: 5, 
    borderRadius: 5,
    width: 330,
    height: 300
  },
  logo: {
    marginBottom: 30
  },
  buttonContainer: {
    flex: 0.5,
    justifyContent: 'center',
    width: '80%',
    alignItems: "center"
  },
  button: {
    flex: 0.25,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: "#6C813C",
    padding: 10,
    margin: 10,
    width: 330,
    borderTopLeftRadius: 15,
    borderTopRightRadius: 15,
    borderBottomRightRadius: 15,
    borderBottomLeftRadius: 15
  },
  textItem: {
    fontSize: 15,
    color: '#34495E',
    padding:5,
    borderBottomWidth: 1,
    borderBottomColor: '#CCC'
  }
})