% =========================================================================
% Script de Simulación del Balance Energético Híbrido - Proyecto SIGE
% Estudiante: Jojan Alejandro
% Curso: Software para Ingeniería (203036)
% Universidad Nacional Abierta y a Distancia (UNAD)
% Descripción: Simulación analítica y dinámica de 24 horas (Solar, Eólica y Demanda)
% =========================================================================

clear; clc; close all;

% Definición del vector temporal (24 horas del día, donde cada posición es una hora)
tiempo = 1:24;

%% a. Generación Solar (P_solar)
% Se inicializa el vector en ceros y se modela la curva diurna con pico a mediodía.
P_solar = zeros(1, 24);
for h = 1:24
    if h >= 6 && h <= 18
        % Función sinusoidal para simular la salida y puesta del sol (Max 25 kW a la hora 12)
        P_solar(h) = 25 * sin(pi * (h - 6) / 12);
    else
        P_solar(h) = 0; % Horas nocturnas (1-5 y 19-24) con 0 kW de radiación
    end
end

%% b. Generación Eólica / Aerogeneradores (P_eolica)
% Simulación de fluctuaciones irregulares del viento con un tope de 15 kW nominales.
rng(5); % Semilla fija para estabilidad en la simulación estocástica
P_eolica = 7 + 4 * sin(tiempo * pi / 4) + 2.5 * randn(1, 24);
% Restricción física: la potencia eólica no baja de 0 ni supera los 15 kW
P_eolica = max(0, min(15, P_eolica));

%% c. Generación Híbrida Total (P_total_hibrida)
% Suma vectorial elemento a elemento de la generación solar y eólica
P_total_hibrida = P_solar + P_eolica;

%% d. Demanda de la Comunidad (P_demanda)
% Perfil de consumo basado en los tres regímenes de carga exigidos por la guía:
P_demanda = zeros(1, 24);
for h = 1:24
    if (h >= 1 && h <= 5) || (h >= 22 && h <= 24)
        % Consumo nocturno mínimo (Horas 1-5 y 22-24): oscila entre 2 kW y 4 kW
        P_demanda(h) = 3 + 0.5 * sin(h);
    elseif h >= 6 && h <= 17
        % Consumo diurno por escuela y bombeo (Horas 6-17): oscila entre 6 kW y 10 kW
        P_demanda(h) = 8 + 1.2 * cos(h * pi / 6);
    else 
        % Pico máximo de demanda (Horas 18-21): alumbrado y retorno doméstico (hasta 15 kW)
        P_demanda(h) = 13.5 + 1.5 * sin(h);
    end
end
% Asegurar límites estrictos de diseño de la demanda (entre 2 y 15 kW)
P_demanda(P_demanda < 2) = 2;
P_demanda(P_demanda > 15) = 15;

%% e. Visualización Gráfica
% Configuración de la figura con fondo blanco para mayor nitidez en el informe
figure('Name', 'Balance Energético - Micro-red SIGE', 'Color', [1 1 1]);

% Graficar la Generación Híbrida Total
plot(tiempo, P_total_hibrida, '-o', 'LineWidth', 2.2, 'Color', [0 0.45 0.74]); 
hold on;

% Graficar la Demanda de la Comunidad
plot(tiempo, P_demanda, '-s', 'LineWidth', 2.2, 'Color', [0.85 0.33 0.10]); 

% Configuración estética de la gráfica exigida en la guía
grid on;
title('Simulación del Balance Energético Híbrido y Demanda en la Micro-red');
xlabel('Tiempo en horas');
ylabel('Potencia en Kilovatios (kW)');
legend('Generación Híbrida Total', 'Demanda de la Comunidad', 'Location', 'NorthWest');
xlim([1 24]);
ylim([0 30]);
hold off;