import { View, Text, StyleSheet, Image, TextInput, TouchableOpacity, ScrollView} from 'react-native'
import React, { useState, useContext } from 'react';
import * as Animatable from 'react-native-animatable'
import { useNavigation } from '@react-navigation/native'
import { AuthContext } from '../contexts/authContext';

export default function TelaLogin() {

  const [nome, setNome] = useState('');
  const [senha, setSenha] = useState('');
  const { logar } = useContext(AuthContext);
  const navigation = useNavigation();

  function clicouEntrar() {
    logar(nome, senha)
  }

  function clicouCadastrar() {
    navigation.navigate('Cadastrar')
  }

  return(
    <ScrollView style={styles.container} contentContainerStyle={{justifyContent: 'center', alignItems: 'center'}}>

      <Animatable.View delay={600} animation="fadeInDown" style={styles.containerTitle}>
          <Text style={styles.title}>RECICLANDO S.A</Text>
      </Animatable.View>
      
      <View style={styles.containerLogo}>
          <Animatable.Image animation="flipInY" source={require("../assets/logo.png")} style={styles.logo}/>
      </View>

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

      <View style={styles.buttonContainer}>
        <TouchableOpacity onPress={clicouEntrar} style={styles.button}>
          <Text style={{ color: "#FFF"}}>ENTRAR</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={clicouCadastrar} style={styles.button}>
          <Text style={{ color: "#FFF"}}>CADASTRAR</Text>
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
  containerLogo: {
    flex: 1,
    backgroundColor: "white",
    justifyContent: 'center',
    alignItems: 'center'
  },
  containerTitle: {
    backgroundColor: "#6C813C",
    justifyContent: 'center',
    alignItems: 'center',
    paddingLeft: 20,
    paddingRight: 20,
    height: 60,
    borderBottomRightRadius: 15,
    borderBottomLeftRadius: 15
  },
  logo: {
    marginBottom: 50
  },
  input: {
    height: 40,
    borderColor: 'gray',
    borderWidth: 1,
    margin: 10,
    padding: 10,
    width: '80%',
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '80%',
    alignItems: "center",
    paddingBottom: 80
  },
  button: {
    flex: 1,
    alignItems: 'center',
    backgroundColor: "#6C813C",
    padding: 10,
    margin: 10,
    borderTopLeftRadius: 15,
    borderTopRightRadius: 15,
    borderBottomRightRadius: 15,
    borderBottomLeftRadius: 15
  }
})