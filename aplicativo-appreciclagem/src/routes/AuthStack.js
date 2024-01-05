import { createNativeStackNavigator } from "@react-navigation/native-stack";
import React from 'react';
import TelaLogin from '../pages/login'
import TelaCadastrar from '../pages/cadastrar'

const Stack = createNativeStackNavigator();

export default function AuthStack() {
    return(
        <Stack.Navigator>
            <Stack.Screen name="Login" component={TelaLogin} />
            <Stack.Screen name="Cadastrar" component={TelaCadastrar} />
        </Stack.Navigator>
    )
}