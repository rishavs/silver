/*---------------------------------
    Users
*/---------------------------------

insert into users (unqid, nickname, flair, email, password) 
values ('user01', 'Adam Sandler', 'Has a secret life', 'adam@mail.com', '$2a$11$hoAmVu39X2S2kOkRDvpTJuxnJ52qwvxld4qA875P4tMdWWJvcWKlS');

insert into users (unqid, nickname, flair, email, password) 
values ('user02', 'Eve Purple', 'Ate a rib', 'eve@mail.com', '$2a$11$JJ208A0w6T94i7g3mMSR0OlIlBKXev84ifakIU3l6TFRKSla.Yv9W');

insert into tags (name, post_id, author_id, voted) 
values ('nature', 'post01', 'user01', 'up');
insert into tags (name, post_id, author_id, voted) 
values ('science', 'post01', 'user01', 'up');
insert into tags (name, post_id, author_id, voted) 
values ('funny', 'post01', 'user01', 'up');
insert into tags (name, post_id, author_id, voted) 
values ('politics', 'post01', 'user01', 'up');
insert into tags (name, post_id, author_id, voted) 
values ('news', 'post01', 'user01', 'up');