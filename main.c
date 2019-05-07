/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rgalyeon <marvin@42.fr>                    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2018/12/11 09:04:05 by rgalyeon          #+#    #+#             */
/*   Updated: 2019/04/20 20:30:55 by rgalyeon         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdlib.h>
#include "get_next_line.h"
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#define WHITE "\x1B[0m"
#define RED "\x1B[31m"
#define GREEN "\x1B[32m"
#define BLUE "\x1B[34m"
#define YELLOW "\x1B[33m"

void	test01(void)
{
	int fd, fd2, fd3;
	int n;
	char *line;
	int file_size;

	/**************************************************************************/
	/*                                                                        */
	/*                           TEST_01_BIG_LINE                             */
	/*                                                                        */
	/**************************************************************************/
	system("mkdir -p tests");
	system("base64 < /dev/urandom | head -c 1000000 | tr -d '\n' | tr -d '\r'  > tests/01_test.txt");

	fd = open("tests/01_test.txt", O_RDONLY);
	fd2 = open("tests/01_test.txt.my", O_CREAT | O_RDWR | O_TRUNC, 0755);
	n = 0;
	while (get_next_line(fd, &line) == 1)
	{
		write(fd2, line, strlen(line));
		free(line);
		n++;
	}
	close(fd);
	close(fd2);

	system("diff tests/01_test.txt tests/01_test.txt.my > tests/01_test.txt.diff");
	fd3 = open("tests/01_test.txt.diff", O_RDONLY);
	file_size = read(fd3, NULL, 10);
	close (fd3);

	if (file_size == 0 && n == 1)
	{
		remove("tests/01_test.txt");
		remove("tests/01_test.txt.my");
		remove("tests/01_test.txt.diff");
		printf("TEST_01_BIG_LINE" GREEN " [OK]\n" WHITE);
	}
	else
	{
		if (n != 1)
		{
			printf("TEST_01_BIG_LINE" RED " [KO]\n" WHITE);
			printf(RED "Yours n - <%d>, ours - <%d>\n" WHITE, n, 1);
		}
		else
			printf("TEST_01_BIG_LINE" RED " DIFFS KO :(\n" WHITE);
	}
}

void	test02(void)
{
	int fd, fd2, fd3;
	int n;
	char *line;
	int file_size;

	/**************************************************************************/
	/*                                                                        */
	/*                          TEST_02_LINE_BREAKS                           */
	/*                                                                        */
	/**************************************************************************/

	system("mkdir -p tests");
	system("echo '\n\n'  > tests/02_test.txt");

	fd = open("tests/02_test.txt", O_RDONLY);
	fd2 = open("tests/02_test.txt.my", O_CREAT | O_RDWR | O_TRUNC, 0755);
	n = 0;
	while (get_next_line(fd, &line) == 1)
	{
		write(fd2, line, strlen(line));
		free(line);
		write(fd2, "\n", 1);
		n++;
	}
	close(fd);
	close(fd2);

	system("diff tests/02_test.txt tests/02_test.txt.my > tests/02_test.txt.diff");
	fd3 = open("tests/02_test.txt.diff", O_RDONLY);
	file_size = read(fd3, NULL, 10);
	close (fd3);

	if (file_size == 0 && n == 3)
	{
		remove("tests/02_test.txt");
		remove("tests/02_test.txt.my");
		remove("tests/02_test.txt.diff");
		printf("TEST_02_LINE_BREAK" GREEN " [OK]\n" WHITE);
	}
	else
	{
		if (n != 3)
		{
			printf("TEST_02_LINE_BREAK" RED " [KO]\n" WHITE);
			printf(RED "Yours n - <%d>, ours - <%d>\n" WHITE, n, 3);
		}
		else
			printf("TEST_02_LINE_BREAK" RED " DIFFS KO :(\n" WHITE);
	}
}

void	test03(void)
{
	int fd, fd2, fd3;
	int n;
	char *line;
	int file_size;

	/**************************************************************************/
	/*                                                                        */
	/*                         TEST_03_EMPTY_LINE                             */
	/*                                                                        */
	/**************************************************************************/

	system("mkdir -p tests");
	system(" > tests/03_test.txt");

	fd = open("tests/03_test.txt", O_RDONLY);
	fd2 = open("tests/03_test.txt.my", O_CREAT | O_RDWR | O_TRUNC, 0755);
	n = 0;
	while (get_next_line(fd, &line) == 1)
	{
		write(fd2, line, strlen(line));
		write(fd2, "\n", 1);
		n++;
	}
	close(fd);
	close(fd2);

	system("diff tests/03_test.txt tests/03_test.txt.my > tests/03_test.txt.diff");
	fd3 = open("tests/03_test.txt.diff", O_RDONLY);
	file_size = read(fd3, NULL, 10);
	close (fd3);

	if (file_size == 0 && n == 0)	
	{
		remove("tests/03_test.txt");
		remove("tests/03_test.txt.my");
		remove("tests/03_test.txt.diff");
		printf("TEST_03_EMPTY_FILE" GREEN " [OK]\n" WHITE);
	}
	else
	{
		if (n != 0)
		{
			printf("TEST_03_EMPTY_FILE" RED " [KO]\n" WHITE);
			printf(RED "Yours n - <%d>, ours - <%d>\n" WHITE, n, 0);
		}
		else
			printf("TEST_03_EMPTY_FILE" RED " DIFFS KO :(\n" WHITE);
	}
}

void	test04(void)
{
	int fd, fd2, fd3;
	int n;
	char *line;
	int file_size;

	/**************************************************************************/
	/*                                                                        */
	/*                           TEST_04_ONE_LINE                             */
	/*                                                                        */
	/**************************************************************************/

	system("mkdir -p tests");
	system("echo 'Tests by rgalyeon! Have a nice day :)'  > tests/04_test.txt");

	fd = open("tests/04_test.txt", O_RDONLY);
	fd2 = open("tests/04_test.txt.my", O_CREAT | O_RDWR | O_TRUNC, 0755);
	n = 0;
	while (get_next_line(fd, &line) == 1)
	{
		write(fd2, line, strlen(line));
		free(line);
		write(fd2, "\n", 1);
		n++;
	}
	close(fd);
	close(fd2);

	system("diff tests/04_test.txt tests/04_test.txt.my > tests/04_test.txt.diff");
	fd3 = open("tests/04_test.txt.diff", O_RDONLY);
	file_size = read(fd3, NULL, 10);
	close (fd3);

	if (file_size == 0 && n == 1)
	{
		remove("tests/04_test.txt");
		remove("tests/04_test.txt.my");
		remove("tests/04_test.txt.diff");
		printf("TEST_04_ONE_LINE" GREEN " [OK]\n" WHITE);
	}
	else
	{
		if (n != 1)
		{
			printf("TEST_04_ONE_LINE" RED " [KO]\n" WHITE);
			printf(RED "Yours n - <%d>, ours - <%d>\n" WHITE, n, 1);
		}
		else
			printf("TEST_04_ONE_LINE" RED " DIFFS KO :(\n" WHITE);
	}
}

void	test05(void)
{
	int fd, fd2, fd3;
	int n;
	char *line;
	ssize_t file_size;

	/**************************************************************************/
	/*                                                                        */
	/*                           TEST_05_8_LINES                              */
	/*                                                                        */
	/**************************************************************************/

	system("mkdir -p tests");
	system("echo 'Hi'  > tests/05_test.txt");
	system("echo 'It is second line'  >> tests/05_test.txt");
	system("echo 'It'  >> tests/05_test.txt");
	system("echo 'is'  >> tests/05_test.txt");
	system("echo 'easy'  >> tests/05_test.txt");
	system("echo 'test'  >> tests/05_test.txt");
	system("echo 'for'  >> tests/05_test.txt");
	system("echo 'you :) Good luck!'  >> tests/05_test.txt");

	fd = open("tests/05_test.txt", O_RDONLY);
	fd2 = open("tests/05_test.txt.my", O_CREAT | O_RDWR | O_TRUNC, 0755);
	n = 0;
	while (get_next_line(fd, &line) == 1)
	{
		write(fd2, line, strlen(line));
		free(line);
		write(fd2, "\n", 1);
		n++;
	}
	close(fd);
	close(fd2);

	system("diff tests/05_test.txt tests/05_test.txt.my > tests/05_test.txt.diff");
	fd3 = open("tests/05_test.txt.diff", O_RDONLY);
	file_size = read(fd3, NULL, 10);
	close (fd3);

	if (file_size == 0 && n == 8)
	{
		remove("tests/05_test.txt");
		remove("tests/05_test.txt.my");
		remove("tests/05_test.txt.diff");
		printf("TEST_05_8_LINES" GREEN " [OK]\n" WHITE);
	}
	else
	{
		if (n != 8)
		{
			printf("TEST_05_8_LINE" RED " [KO]\n" WHITE);
			printf(RED "Yours n - <%d>, ours - <%d>\n" WHITE, n, 8);
		}
		else
			printf("TEST_05_8_LINE" RED " DIFFS [KO] :(\n" WHITE);
	}
}

void	test06(void)
{
	int fd, fd2, fd3;
	int n;
	char *line;
	ssize_t file_size;

	/**************************************************************************/
	/*                                                                        */
	/*                       TEST_06_by_vlegros                               */
	/*                                                                        */
	/**************************************************************************/

	system("mkdir -p tests");
	system("echo ''  > tests/06_test.txt");
	system("echo 'test test' | tr -d '\n'  >> tests/06_test.txt");

	fd = open("tests/06_test.txt", O_RDONLY);
	fd2 = open("tests/06_test.txt.my", O_CREAT | O_RDWR | O_TRUNC, 0755);
	n = 0;
	while (get_next_line(fd, &line) == 1)
	{
		write(fd2, line, strlen(line));
		if (n == 0)
			write(fd2, "\n", 1);
		free(line);
		n++;
	}
	close(fd);
	close(fd2);

	system("diff tests/06_test.txt tests/06_test.txt.my > tests/06_test.txt.diff");
	fd3 = open("tests/06_test.txt.diff", O_RDONLY);
	file_size = read(fd3, NULL, 10);
	close (fd3);

	if (file_size == 0 && n == 2)
	{
		remove("tests/06_test.txt");
		remove("tests/06_test.txt.my");
		remove("tests/06_test.txt.diff");
		printf("TEST_06_by_vlegros" GREEN " [OK]\n" WHITE);
	}
	else
	{
		if (n != 2)
		{
			printf("TEST_06_by_vlegros" RED " [KO]\n" WHITE);
			printf(RED "Yours n - <%d>, ours - <%d>\n" WHITE, n, 2);
		}
		else
			printf("TEST_06_by_vlegros" RED " DIFFS [KO] :(\n" WHITE);
	}
}


void	test07(void)
{
	int fd;
	int out;
	int p[2];
	char *line;
	int n = 0;

	/**************************************************************************/
	/*                                                                        */
	/*                       TEST_07_FOUR_LINES                               */
	/*                                                                        */
	/**************************************************************************/

	fd = 1;
	out = dup(fd);
	pipe(p);

	dup2(p[1], fd);
	write(fd, "lol\nkek\nbek\nmek\n", 16);
	dup2(out, fd);
	close(p[1]);
	get_next_line(p[0], &line);
	if (strcmp(line, "lol") == 0)
		n++;
	free(line);
	get_next_line(p[0], &line);
	if (strcmp(line, "kek") == 0)
		n++;
	free(line);
	get_next_line(p[0], &line);
	if (strcmp(line, "bek") == 0)
		n++;
	free(line);
	get_next_line(p[0], &line);
	if (strcmp(line, "mek") == 0)
		n++;
	free(line);
	if (get_next_line(p[0], &line) == 0)
	{
		if (n == 4)
			printf("TEST_07_FOUR_LINES" GREEN " [OK]\n" WHITE);
	}
	else
		if (n != 4)
		{
			free(line);
			printf("TEST_07_FOUR_LINES" RED " [KO]\n" WHITE);
			printf(RED "Yours n - <%d>, ours - <%d>\n" WHITE, n, 4);
		}
		else
		{
			free(line);
			printf("TEST_07_FOUR_LINES" RED " DIFFS [KO] :(\n" WHITE);
		}
}


void	test08(void)
{
	int fd;
	int out;
	int p[2];
	char *line;
	int n = 0;

	/**************************************************************************/
	/*                                                                        */
	/*                            TEST_08_STDIN                               */
	/*                                                                        */
	/**************************************************************************/

	fd = 1;
	out = dup(fd);
	pipe(p);

	dup2(p[1], fd);
	write(fd, "lolkekcheburek", 14);
	dup2(out, fd);
	close(p[1]);
	get_next_line(p[0], &line);
	if (strcmp(line, "lolkekcheburek") == 0)
		n++;
	free(line);
	if (get_next_line(p[0], &line) == 0)
	{
		if (n == 1)
			printf("TEST_08_STDIN" GREEN " [OK]\n" WHITE);
	}
	else
		if (n != 1)
		{
			printf("TEST_08_STDIN" RED " [KO]\n" WHITE);
			printf(RED "Yours n - <%d>, ours - <%d>\n" WHITE, n, 1);
		}
		else
			printf("TEST_08_STDIN" RED " DIFFS [KO] :(\n" WHITE);
}

void	test09(void)
{
	int fd, fd2, fd3;
	int n;
	char *line;
	ssize_t file_size;

	/**************************************************************************/
	/*                                                                        */
	/*                       TEST_09_ZERO_BYTES                               */
	/*                                                                        */
	/**************************************************************************/

	system("mkdir -p tests");
	system(" > tests/09_test.txt");
	system("dd if=/dev/zero of=tests/09_test.txt bs=100 count=5 &> /dev/null");

	fd = open("tests/09_test.txt", O_RDONLY);
	fd2 = open("tests/09_test.txt.my", O_CREAT | O_RDWR | O_TRUNC, 0755);
	n = 0;
	while (get_next_line(fd, &line) == 1)
	{
		write(fd2, line, 500);
		free(line);
		n++;
	}
	close(fd);
	close(fd2);

	system("diff tests/09_test.txt tests/09_test.txt.my > tests/09_test.txt.diff");
	fd3 = open("tests/09_test.txt.diff", O_RDONLY);
	file_size = read(fd3, NULL, 10);
	close (fd3);

	if (file_size == 0 && n == 0)
	{
		remove("tests/09_test.txt");
		remove("tests/09_test.txt.my");
		remove("tests/09_test.txt.diff");
		printf("TEST_09_ZERO_BYTES" GREEN " [OK]\n" WHITE);
	}
	else
	{
		if (n != 0)
		{
			printf("TEST_09_ZERO_BYTES" RED " [KO]\n" WHITE);
			printf(RED "Yours n - <%d>, ours - <%d>\n" WHITE, n, 0);
		}
		else
			printf("TEST_09_~ERO_BYTES" RED " DIFFS [KO] :(\n" WHITE);
	}
}


void	test10(void)
{
	int fd;
	int n;
	char *line;

	/**************************************************************************/
	/*                                                                        */
	/*                           TEST_10_BAD_FD                               */
	/*                                                                        */
	/**************************************************************************/

	system("mkdir -p tests");

	fd = -1;
	n = 0;

	if (get_next_line(fd, &line) == -1 && n == 0)
		printf("TEST_10_BAD_FD" GREEN " [OK]\n" WHITE);
	else
		printf("TEST_10_BAD_FD" RED " DIFFS [KO] :(\n" WHITE);
}


void	test11(void)
{
	int fd, fd2;
	char *line;

	/**************************************************************************/
	/*                                                                        */
	/*                           TEST_11_MUL_FD                               */
	/*                                                                        */
	/**************************************************************************/

	system("mkdir -p tests");
	system("echo 'lol\ncheburek' > tests/11_test.txt");
	system("echo 'kek' > tests/11_test1.txt");

	fd = open("tests/11_test.txt", O_RDONLY);
	fd2 = open("tests/11_test1.txt", O_RDONLY);

	get_next_line(fd, &line);
	if (strcmp(line, "lol") == 0)
	{
		free(line);
		get_next_line(fd2, &line);
		if (strcmp(line, "kek") == 0)
		{
			free(line);
			get_next_line(fd, &line);
			if (strcmp(line, "cheburek") == 0)
			{
				free(line);
				remove("tests/11_test.txt");
				remove("tests/11_test1.txt");
				printf("TEST_11_MUL_FD" GREEN " [OK]\n" WHITE);
				return ;
			}
		}
	}
	close(fd);
	close(fd2);
	printf("TEST_11_MUL_FD" RED " DIFFS [KO] :(\n" WHITE);
}

int		main()
{
	test01();
	test02();
	test03();
	test04();
	test05();
	test06();
	test07();
	test08();
	test09();
	test10();
	test11();
}
