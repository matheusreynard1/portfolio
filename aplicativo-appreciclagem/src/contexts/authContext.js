import React, { createContext, useState } from 'react';
import { useNavigation } from '@react-navigation/native';
import axios from 'axios';

export const AuthContext = createContext({})

function AuthProvider({ children }) {
    const navigation = useNavigation();
    const [user, setUser] = useState({});
    const [authState, setAuthState] = useState(false);
    const [tokenRecebido, setTokenRecebido] = useState();

    async function logar(nome, senha) {

        const dadosFormulario = {
            login: nome,
            senha: senha
        };

        if (nome == '' || nome == undefined || senha == '' || senha == undefined) {
            alert('Nome e Senha são obrigatórios.')
        } else {
            try {
                const response = await axios.post('http://10.0.2.2:6565/empresa/login', dadosFormulario);
                if (response.data !== 'Credenciais inválidas.') {
                    setTokenRecebido(response.data);
                    setUser({
                        nome: nome
                    })
                    setAuthState(true);
                    navigation.navigate('Início')
                } else {
                    alert('Credenciais inválidas.')
                }
            } catch (error) {
                console.error('Erro ao autenticar:', error.message);
            }
        }
    }


    return (
        <AuthContext.Provider value={{ logar, user, authState, setAuthState, tokenRecebido}}>
            {children}
        </AuthContext.Provider>
    )
}

export default AuthProvider;