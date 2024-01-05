import { createNativeStackNavigator } from "@react-navigation/native-stack";
import React from 'react';
import TelaInicial from '../pages/inicial'

const Stack = createNativeStackNavigator();

export default function AppStack() {
    return(
        <Stack.Navigator>
            <Stack.Screen name="Início" component={TelaInicial} />
        </Stack.Navigator>
    )
}