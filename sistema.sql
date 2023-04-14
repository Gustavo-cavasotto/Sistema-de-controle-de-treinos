/* Sistema de controle de treinos para academia - Um sistema que permite o gerenciamento de treinos de alunos em uma academia. Possui funcionalidades como cadastro de alunos e treinadores, registro dos treinos realizados por cada aluno, definição de objetivos e metas de treinamento, acompanhamento do desempenho dos alunos, criação de programas de treinamento, entre outras. O sistema também deve permitir o controle de acesso à academia e gerar relatórios estatísticos sobre o desempenho dos alunos. Para o banco de dados, sugere-se criar tabelas para alunos, treinadores, treinos, objetivos, metas e acesso à academia.*/
CREATE TABLE alunos (
    id INTEGER PRIMARY KEY,
    nome CHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    cpf CHAR(100) NOT NULL,
    endereco CHAR(100),
    telefone CHAR(100),
    email CHAR(100),
    data_cadastro DATE NOT NULL
);

CREATE TABLE treinadores (
    id INTEGER PRIMARY KEY,
    nome CHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL,
    endereco CHAR(100),
    telefone CHAR(9),
    email CHAR(100),
    data_contratacao DATE NOT NULL,
    especialidade CHAR NOT NULL
    FOREIGN KEY (especialidade) REFERENCES treinadores_especialidades(id)
    	ON UPDATE CASCADE
    	ON DELETE RESTRICT
);

CREATE TABLE treinadores_especialidades
(
	id INTEGER PRIMARY KEY,
	especialidade CHAR(50) NOT NULL
)

CREATE TABLE treinos (
    id INTEGER PRIMARY KEY,
    id_aluno INTEGER NOT NULL,
    id_treinador INTEGER NOT NULL,
    data_treino DATE NOT NULL,
    id_tipo_treino INTEGER NOT NULL,
    FOREIGN KEY (id_aluno) REFERENCES alunos (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (id_treinador) REFERENCES treinadores (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (id_tipo_treino) REFERENCES tipos_treinos (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE tipos_treinos (
	id INTEGER PRIMARY KEY,
	descricao_treino CHAR(50) NOT NULL,
	tempo_treino INTEGER NOT NULL,
   intensidade_treino CHAR(50) NOT NULL
)

CREATE TABLE objetivos (
    id INTEGER PRIMARY KEY,
    id_aluno INTEGER NOT NULL,
    objetivo CHAR(100) NOT NULL,
    data_cadastro DATE NOT NULL,
    FOREIGN KEY (id_aluno) REFERENCES alunos (id)
    	ON UPDATE CASCADE
    	ON DELETE RESTRICT
);

CREATE TABLE acesso (
    id INTEGER PRIMARY KEY,
    id_aluno INTEGER NOT NULL,
    data_acesso DATE NOT NULL,
    hora_acesso TIME NOT NULL,
    FOREIGN KEY (id_aluno) REFERENCES alunos (id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE
);


/* INSERTS */

INSERT INTO alunos (id, nome, data_nascimento, cpf, endereco, telefone, email, data_cadastro) VALUES
(1, 'Cassio', '1990-05-10', '123.456.789-00', 'Rua A, 123', '(11) 99999-9999', 'cassio.costa@rede.ulbra.br',
'2022-01-01'),
(2, 'Gustavo', '1995-08-20', '987.654.321-00', 'Rua B, 456', '(11) 88888-8888', 'gustavocpotrich@rede.ulbra.br',
'2023-10-04');
(3, 'Clovis', '1995-08-20', '987.654.321-00', 'Rua B, 456', '(11) 88888-8888', 'clovis@rede.ulbra.br',
'2022-10-04');

INSERT INTO treinadores (id, nome, cpf, endereco, telefone, email, data_contratacao, especialidade) VALUES
(1, 'Arnold Schwarzenegger', '111.222.333-44', 'Av. C, 789', '(11) 77777-7777', 'arnold@email.com',
'2020-01-01', 1),
(2, 'Renato Cariani', '444.555.666-77', 'Av. D, 456', '(11) 66666-6666', 'renatocariri@email.com',
'2021-01-01', 2);


INSERT INTO tipos_treinos (id, descricao_treino, tempo_treino, intensidade_treino) VALUES
(1, 'Peito e Triceps', 80, 'Até a Falha'),
(2, 'Glúteos e Posterior', 90, 'Até queimar'),
(3, 'Mobilidade de Ombro', 40, 'Moderada');

INSERT INTO treinos (id, id_aluno, id_treinador, data_treino, id_tipo_treino)
VALUES
(1, 1, 1, '2023-04-13', 2),
(2, 2, 1, '2023-04-13', 1);

INSERT INTO objetivos (id, id_aluno, objetivo, data_cadastro) VALUES
(1, 1, 'Perder peso', '2023-01-01'),
(2, 2, 'Ganhar massa muscular', '2023-01-01');

INSERT INTO acesso (id, id_aluno, data_acesso, hora_acesso) VALUES

(7, 2, '2023-04-13', '05:00:00');



/* VIEWS */

/* Mostre todos os alunos que ja treinaram com o professor arnold schwarzenegger */
CREATE VIEW alunos_que_treinam_com_arnold AS
SELECT alunos.nome, treinos.data_treino, treinadores.nome AS nome_treinador
FROM treinadores 
INNER JOIN treinos ON treinos.id_treinador = treinadores.id
INNER JOIN alunos ON alunos.id = treinos.id_aluno
WHERE treinos.id_treinador = 1;

SELECT * FROM alunos_que_treinam_com_arnold;


/* Todos os alunos que estão matriculados, e o total de treinos realizados */
CREATE VIEW alunos_miguezentos AS 
SELECT alunos.nome, COUNT(treinos.id) AS total_de_treinos, treinos.data_treino
FROM alunos
LEFT JOIN treinos ON treinos.id_aluno = alunos.id
GROUP BY alunos.nome;

SELECT * FROM alunos_miguezentos;

/* Quantos alunos treinaram depois 18 horas do dia atual */ 

CREATE VIEW treinos_noturnos AS
SELECT alunos.nome, acesso.hora_acesso, acesso.data_acesso
FROM alunos
INNER JOIN acesso ON acesso.id_aluno = alunos.id
WHERE acesso.hora_acesso > '18:00' AND acesso.data_acesso = CURDATE()

SELECT * FROM treinos_noturnos;

/* PROCEDURES */
/* Verificando horário de acesso */
CREATE PROCEDURE verifica_horario_acesso(
	IN id_param INTEGER,
    IN id_aluno_param INTEGER,
    IN data_acesso_param DATE,
    IN hora_acesso_in TIME
)
BEGIN
    IF hora_acesso_in < '06:00:00' OR hora_acesso_in > '23:59:00' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_CHAR = 'A hora de acesso deve estar entre 6:00 e 23:59';
    ELSE
        INSERT INTO acesso (id, id_aluno, data_acesso, hora_acesso)
        VALUES (id_param, id_aluno_param, data_acesso_param, hora_acesso_in);
        SELECT "Acesso registrado com sucesso.";
    END IF;
END //



CALL verifica_horario_acesso(8, 2, '2023-04-13', '08:00:00');


/*Verificando se o aluno é maior de 14 anos */
CREATE PROCEDURE registrar_aluno(
	 IN id_param INTEGER,
    IN nome_param CHAR,
    IN data_nascimento_param DATE,
    IN cpf_param CHAR,
    IN endereco_param CHAR,
    IN telefone_param CHAR, 
    IN email_param CHAR,
    IN data_cadastro_param DATE
)
BEGIN
    DECLARE idade INT;
    SET idade = TIMESTAMPDIFF(YEAR, data_nascimento_param, CURDATE()); /*YEAR SIGNIFICA QUE QUEREMO CALCULAR A DIFERENÇA DAS DATAS SE REFERINDO AOS ANOS*/
    
    IF idade < 14 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_CHAR = 'Não é possível inserir um aluno com menos de 14 anos.';
    ELSE
        INSERT INTO alunos (id, nome, data_nascimento, cpf, endereco, telefone, email, data_cadastro)
        VALUES (id_param, nome_param, data_nascimento_param, cpf_param, endereco_param, telefone_param, email_param, data_cadastro_param);
    END IF;
END //
DELIMITER ;

CALL registrar_aluno(5, 'Clovis Junior', '2022-08-20', '987.654.321-00', 'Rua B, 456', '(11) 88888-8888', 'clovis@rede.ulbra.br',
'2022-10-04');



DELIMITER //
CREATE PROCEDURE criar_tipo_treino(
IN id_param INTEGER,
IN descricao_treino_param CHAR,
IN tempo_treino_param INT,
IN intensidade_treino_param CHAR
)
BEGIN
IF tempo_treino_param > 150 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_CHAR = 'Não é permitido criar um treino maior que 2 horas e meia devido ao risco de lesões.';
ELSE
INSERT INTO tipos_treinos (id, descricao_treino, tempo_treino, intensidade_treino)
VALUES (id_param, descricao_treino_param, tempo_treino_param, intensidade_treino_param);
END IF;
END;
//
DELIMITER ;

CALL criar_tipo_treino(8, 'Peito', 510, 'Até a falha');


DELIMITER //
CREATE PROCEDURE criar_treino(IN id_param INT, IN id_aluno_param INT, IN id_treinador_param INT, IN data_treino_param DATE, IN id_tipo_treino_param INT)
BEGIN 
	IF NOT EXISTS (SELECT id FROM treinos WHERE id_aluno = id_aluno_param AND id_treinador = id_treinador_param AND data_treino = data_treino_param AND id_tipo_treino = id_tipo_treino_param ) THEN
		INSERT INTO treinos (id, id_aluno, id_treinador, data_treino, id_tipo_treino) VALUES (id_param, id_aluno_param, id_treinador_param, data_treino_param, id_tipo_treino_param);
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O aluno já fez esse tipo de treino nessa data.';
	END IF;
END;
//
DELIMITER ;
CALL criar_treino(6, 1, 1, '2023-04-17', 1)
 

DELIMITER //
CREATE PROCEDURE registrar_treinador(IN id INT, IN nome CHAR, IN cpf CHAR, IN endereco CHAR, IN telefone CHAR, IN email CHAR, IN data_contratacao DATE, IN anos_experiencia INT, IN especialidade CHAR)
BEGIN 
	IF anos_experiencia < 4 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_CHAR = 'Esse treinador não possui os requisitos mínimos para ser contratado';
	ELSE
		INSERT INTO treinadores(id, nome, cpf, endereco, telefone, email, data_contratacao, anos_experiencia, especialidade) VALUES (id, nome, cpf, endereco, telefone, email, data_contratacao, anos_experiencia, especialidade);
	END IF;
END;
//
DELIMITER;

CALL registrar_treinador(5, "Joaozinho", "123-123-123-04", "Torres", "99999999", "a@a.com", "2023-04-14", 3, 1)

/* fim procedures */
