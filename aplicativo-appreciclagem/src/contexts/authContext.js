import React, { createContext, useState } from 'react';
import { useNavigation } from '@react-navigation/native';

export const AuthContext = createContext({})

function AuthProvider({ children }) {
    const navigation = useNavigation();
    const [user, setUser] = useState({});
    const [authState, setAuthState] = useState(false);

    function logar(nome, senha) {
        if (nome == '' || nome == undefined || senha == '' || senha == undefined) {
            alert('Nome e Senha são obrigatórios.')
        } else {
            setUser({
                nome: nome
            })
            setAuthState(true);
            navigation.navigate('Início')
        }
    }

    return (
        <AuthContext.Provider value={{ logar, user, authState, setAuthState}}>
            {children}
        </AuthContext.Provider>
    )
}

export default AuthProvider;